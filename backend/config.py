import os


# ============================================================
# BACKEND DIRECTORY
# ============================================================

BASE_DIR = os.path.dirname(
    os.path.abspath(__file__)
)


# ============================================================
# MODEL
# ============================================================

MODEL_PATH = os.path.abspath(
    os.path.join(
        BASE_DIR,
        "..",
        "model",
        "gingiva_dopi_classifier.keras"
    )
)


# ============================================================
# UPLOAD / RESULT DIRECTORIES
# ============================================================

UPLOAD_FOLDER = os.path.join(
    BASE_DIR,
    "uploads"
)


RESULT_FOLDER = os.path.join(
    BASE_DIR,
    "results"
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


# ============================================================
# ALLOWED IMAGE TYPES
# ============================================================

ALLOWED_EXTENSIONS = {
    "jpg",
    "jpeg",
    "png"
}


# ============================================================
# CREATE DIRECTORIES
# ============================================================

os.makedirs(
    UPLOAD_FOLDER,
    exist_ok=True
)

os.makedirs(
    RESULT_FOLDER,
    exist_ok=True
)