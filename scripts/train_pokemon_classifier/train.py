"""
Trains a MobileNetV2 Pokemon classifier on Gen 1 sprites and exports a
quantized INT8 TFLite model (~1-2 MB) ready for on-device inference.

Usage:
    # 1. Download sprites first
    python download_dataset.py

    # 2. Train and export
    python train.py

    # 3. Copy output to Flutter assets
    cp output/pokemon_classifier.tflite ../../assets/models/

Recommended: run with a GPU (CUDA) for faster training.
CPU training works but takes longer (~5-10 min for phase 1).
"""

import numpy as np
import tensorflow as tf
from pathlib import Path

# ── Config ────────────────────────────────────────────────────────────────────
IMG_SIZE = 224
NUM_CLASSES = 151
BATCH_SIZE = 16          # small dataset, keep batches small
EPOCHS_FROZEN = 30       # phase 1: top layer only
EPOCHS_FINE_TUNE = 15    # phase 2: unfreeze last 50 layers
DATASET_DIR = Path('dataset')
OUTPUT_DIR = Path('output')

# ── Dataset ───────────────────────────────────────────────────────────────────

def load_dataset():
    images, labels = [], []

    for i in range(1, NUM_CLASSES + 1):
        img_path = DATASET_DIR / f'{i:03d}.png'
        if not img_path.exists():
            print(f'  Warning: {img_path} not found, skipping class {i}')
            continue

        img = tf.keras.utils.load_img(
            str(img_path),
            color_mode='rgb',
            target_size=(IMG_SIZE, IMG_SIZE),
        )
        images.append(tf.keras.utils.img_to_array(img))
        labels.append(i - 1)  # 0-indexed; dex_id = label_index + 1

    X = np.array(images, dtype=np.float32)
    y = np.array(labels, dtype=np.int32)
    print(f'Loaded {len(X)} images across {len(set(labels))} classes')
    return X, y


def make_augmented_dataset(X, y):
    augment = tf.keras.Sequential([
        tf.keras.layers.RandomFlip('horizontal'),
        tf.keras.layers.RandomRotation(0.15),
        tf.keras.layers.RandomZoom(0.2),
        tf.keras.layers.RandomTranslation(0.1, 0.1),
        tf.keras.layers.RandomBrightness(0.25),
        tf.keras.layers.RandomContrast(0.2),
    ])

    ds = tf.data.Dataset.from_tensor_slices((X, y))
    ds = ds.shuffle(len(X), reshuffle_each_iteration=True)
    ds = ds.map(
        lambda x, lbl: (augment(x, training=True), lbl),
        num_parallel_calls=tf.data.AUTOTUNE,
    )
    return ds.batch(BATCH_SIZE).prefetch(tf.data.AUTOTUNE)

# ── Model ─────────────────────────────────────────────────────────────────────

def build_model():
    base = tf.keras.applications.MobileNetV2(
        input_shape=(IMG_SIZE, IMG_SIZE, 3),
        include_top=False,
        weights='imagenet',
    )
    base.trainable = False

    inputs = tf.keras.Input(shape=(IMG_SIZE, IMG_SIZE, 3))
    # preprocess_input baked in — Flutter passes raw [0, 255] float32 values
    x = tf.keras.applications.mobilenet_v2.preprocess_input(inputs)
    x = base(x, training=False)
    x = tf.keras.layers.GlobalAveragePooling2D()(x)
    x = tf.keras.layers.Dropout(0.3)(x)
    outputs = tf.keras.layers.Dense(NUM_CLASSES, activation='softmax')(x)

    return tf.keras.Model(inputs, outputs), base

# ── Training ──────────────────────────────────────────────────────────────────

def train(X, y):
    model, base = build_model()
    dataset = make_augmented_dataset(X, y)

    # Phase 1: frozen base, train head only
    print('\n── Phase 1: training head (base frozen) ─────────────────────────')
    model.compile(
        optimizer=tf.keras.optimizers.Adam(1e-3),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy'],
    )
    model.fit(dataset, epochs=EPOCHS_FROZEN)

    # Phase 2: unfreeze last 50 layers, fine-tune with low LR
    print('\n── Phase 2: fine-tuning (last 50 layers unfrozen) ───────────────')
    base.trainable = True
    for layer in base.layers[:-50]:
        layer.trainable = False

    model.compile(
        optimizer=tf.keras.optimizers.Adam(1e-5),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy'],
    )
    model.fit(dataset, epochs=EPOCHS_FINE_TUNE)

    return model

# ── TFLite export ─────────────────────────────────────────────────────────────

def representative_dataset(X):
    # Feeds raw pixel values — preprocess_input is inside the model
    def gen():
        for i in range(min(100, len(X))):
            yield [X[i:i + 1]]
    return gen


def export_tflite(model, X):
    OUTPUT_DIR.mkdir(exist_ok=True)

    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.representative_dataset = representative_dataset(X)
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
    # Keep float32 I/O so Flutter doesn't need to handle quantized bytes
    converter.inference_input_type = tf.float32
    converter.inference_output_type = tf.float32

    tflite_bytes = converter.convert()

    out_path = OUTPUT_DIR / 'pokemon_classifier.tflite'
    out_path.write_bytes(tflite_bytes)

    size_mb = len(tflite_bytes) / (1024 * 1024)
    print(f'\nSaved: {out_path}  ({size_mb:.2f} MB)')
    print('Next step: copy to your Flutter project —')
    print('  cp output/pokemon_classifier.tflite ../../assets/models/')


# ── Entry point ───────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print(f'TensorFlow {tf.__version__}')
    print(f'GPU available: {bool(tf.config.list_physical_devices("GPU"))}')

    X, y = load_dataset()
    model = train(X, y)
    export_tflite(model, X)
