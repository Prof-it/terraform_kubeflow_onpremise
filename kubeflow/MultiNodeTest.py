import tensorflow as tf
import pickle
import numpy as np
import time
import json
from itertools import product
import os

# Hyperparameter configurations
BATCH_SIZES = [32, 64, 128]
LEARNING_RATES = [0.001, 0.0005, 0.01]
EPOCHS_LIST = [10, 20, 30]

# Multi-worker cluster configuration
TF_CONFIG = {
    "cluster": {
        "worker": ["192.168.178.110:12345", "192.168.178.111:12345"]
    },
    "task": {"type": "worker", "index": 0}
}
os.environ["TF_CONFIG"] = json.dumps(TF_CONFIG)

# Load CIFAR-10 data
def load_cifar10(path):
    with open(path, 'rb') as f:
        data_dict = pickle.load(f, encoding='bytes')
    return data_dict[b'data'], np.array(data_dict[b'labels'])

x_train, y_train = load_cifar10('/home/ubuntu/cifar/cifar-10-batches-py/data_batch_1')
x_test, y_test = load_cifar10('/home/ubuntu/cifar/cifar-10-batches-py/test_batch')

# Reshape and normalize
x_train = x_train.reshape(-1, 3, 32, 32).transpose(0, 2, 3, 1) / 255.0
x_test = x_test.reshape(-1, 3, 32, 32).transpose(0, 2, 3, 1) / 255.0

# Initialize MultiWorkerMirroredStrategy
strategy = tf.distribute.MultiWorkerMirroredStrategy()

# Benchmark loop
for batch_size, learning_rate, epochs in product(BATCH_SIZES, LEARNING_RATES, EPOCHS_LIST):
    with strategy.scope():
        model = tf.keras.applications.ResNet50(weights=None, input_shape=(32, 32, 3), classes=10)
        optimizer = tf.keras.optimizers.Adam(learning_rate=learning_rate)
        model.compile(optimizer=optimizer, loss='sparse_categorical_crossentropy', metrics=['accuracy'])

    print(f"Starting benchmark: Batch Size={batch_size}, Learning Rate={learning_rate}, Epochs={epochs}")
    start_time = time.time()

    history = model.fit(
        x_train, y_train,
        validation_data=(x_test, y_test),
        epochs=epochs,
        batch_size=batch_size * strategy.num_replicas_in_sync
    )

    end_time = time.time()
    elapsed_time = end_time - start_time
    final_val_acc = history.history['val_accuracy'][-1]

    print(f"Completed: Batch Size={batch_size}, Learning Rate={learning_rate}, Epochs={epochs}")
    print(f"Elapsed Time: {elapsed_time:.2f} seconds")
    print(f"Final Validation Accuracy: {final_val_acc:.4f}")