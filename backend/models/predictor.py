# ============================================================
# MELANOSCAN AI - MODEL PREDICTOR
# ============================================================

import os
import numpy as np
import tensorflow as tf


# ============================================================
# MODEL PATH
# ============================================================

BASE_DIR = os.path.dirname(
    os.path.dirname(
        os.path.abspath(__file__)
    )
)


MODEL_PATH = os.path.abspath(
    os.path.join(
        BASE_DIR,
        "..",
        "model",
        "gingiva_dopi_classifier.keras"
    )
)


# ============================================================
# MODEL SETTINGS
# ============================================================

IMAGE_SIZE = 224


CLASS_NAMES = [
    "DOPI_0",
    "DOPI_1",
    "DOPI_2",
    "DOPI_3"
]


CLASS_DESCRIPTIONS = {
    0: "No Clinical Pigmentation",
    1: "Mild Pigmentation",
    2: "Moderate Pigmentation",
    3: "Severe Pigmentation"
}


# ============================================================
# LOAD MODEL
# ============================================================

if not os.path.exists(
    MODEL_PATH
):

    raise FileNotFoundError(
        "Trained model not found:\n"
        + MODEL_PATH
    )


print()
print("=" * 60)
print("LOADING MELANOSCAN AI MODEL")
print("=" * 60)

print(
    "Model path:",
    MODEL_PATH
)


model = tf.keras.models.load_model(
    MODEL_PATH
)


print(
    "Model loaded successfully."
)


# ============================================================
# PREDICT DOPI
# ============================================================

def predict_dopi(
    image
):

    """
    Predict DOPI grade from a prepared
    224 x 224 RGB image.

    Expected input:
        NumPy array with shape
        (224, 224, 3)
    """


    # --------------------------------------------------------
    # Validate input
    # --------------------------------------------------------

    if image is None:

        raise ValueError(
            "Input image is None."
        )


    # --------------------------------------------------------
    # Resize if necessary
    # --------------------------------------------------------

    if (
        image.shape[0] != IMAGE_SIZE
        or
        image.shape[1] != IMAGE_SIZE
    ):

        import cv2

        image = cv2.resize(
            image,
            (
                IMAGE_SIZE,
                IMAGE_SIZE
            ),
            interpolation=cv2.INTER_AREA
        )


    # --------------------------------------------------------
    # Convert to float32
    # --------------------------------------------------------

    image = image.astype(
        np.float32
    )


    # --------------------------------------------------------
    # Add batch dimension
    # --------------------------------------------------------

    input_image = np.expand_dims(
        image,
        axis=0
    )


    # --------------------------------------------------------
    # MODEL PREDICTION
    # --------------------------------------------------------

    probabilities = model.predict(
        input_image,
        verbose=0
    )[0]


    # --------------------------------------------------------
    # GET PREDICTED CLASS
    # --------------------------------------------------------

    predicted_class = int(
        np.argmax(
            probabilities
        )
    )


    confidence = float(
        probabilities[
            predicted_class
        ]
    )


    # --------------------------------------------------------
    # CREATE RESULT
    # --------------------------------------------------------

    result = {

        "dopi_grade":
            predicted_class,

        "class_name":
            CLASS_NAMES[
                predicted_class
            ],

        "classification":
            CLASS_DESCRIPTIONS[
                predicted_class
            ],

        "confidence":
            confidence,

        "confidence_percent":
            confidence * 100,

        "probabilities": {

            CLASS_NAMES[i]:
                float(
                    probabilities[i]
                )

            for i in range(
                len(CLASS_NAMES)
            )
        }
    }


    return result


# ============================================================
# MODEL INFORMATION
# ============================================================

def get_model_info():

    return {

        "model":
            "EfficientNetB0",

        "input_size":
            IMAGE_SIZE,

        "classes":
            CLASS_NAMES,

        "model_path":
            MODEL_PATH
    }


print(
    "Predictor module ready."
)