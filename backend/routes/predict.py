# ============================================================
# MELANOSCAN AI - PREDICTION ROUTE
# ============================================================

import os
import uuid

from flask import Blueprint, request, jsonify

from models.predictor import predict_dopi
from models.image_processing import prepare_image_from_file
from config import UPLOAD_FOLDER


# ============================================================
# CREATE BLUEPRINT
# ============================================================

predict_bp = Blueprint(
    "predict",
    __name__
)


# ============================================================
# ALLOWED IMAGE TYPES
# ============================================================

ALLOWED_EXTENSIONS = {
    "jpg",
    "jpeg",
    "png",
    "webp"
}

ALLOWED_MIME_TYPES = {
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/webp",
    "application/octet-stream"
}


# ============================================================
# CHECK IMAGE FILE
# ============================================================

def allowed_file(file):

    filename = file.filename or ""
    content_type = (file.content_type or "").lower()

    # --------------------------------------------------------
    # Check filename extension
    # --------------------------------------------------------

    if "." in filename:

        extension = filename.rsplit(
            ".",
            1
        )[1].lower()

        if extension in ALLOWED_EXTENSIONS:
            return True

    # --------------------------------------------------------
    # Android may send WebP with application/octet-stream
    # --------------------------------------------------------

    if content_type in ALLOWED_MIME_TYPES:
        return True

    return False


# ============================================================
# GET SAFE EXTENSION
# ============================================================

def get_extension(file):

    filename = file.filename or ""
    content_type = (file.content_type or "").lower()

    # --------------------------------------------------------
    # Use filename extension when available
    # --------------------------------------------------------

    if "." in filename:

        extension = filename.rsplit(
            ".",
            1
        )[1].lower()

        if extension == "jpg":
            return ".jpg"

        if extension == "jpeg":
            return ".jpg"

        if extension == "png":
            return ".png"

        if extension == "webp":
            return ".webp"

    # --------------------------------------------------------
    # Fallback to MIME type
    # --------------------------------------------------------

    if content_type in {
        "image/jpeg",
        "image/jpg"
    }:
        return ".jpg"

    if content_type == "image/png":
        return ".png"

    if content_type == "image/webp":
        return ".webp"

    # Android sometimes reports WebP as octet-stream.
    # Use WebP as the fallback when no extension is available.
    if content_type == "application/octet-stream":
        return ".webp"

    return ".jpg"


# ============================================================
# PREDICTION ENDPOINT
# ============================================================

@predict_bp.route(
    "/predict",
    methods=["POST"]
)
def predict():

    # ========================================================
    # DIAGNOSTIC INFORMATION
    # ========================================================

    print("=" * 60)
    print("PREDICT REQUEST RECEIVED")
    print(
        "Content-Type:",
        request.content_type
    )
    print(
        "Content-Length:",
        request.content_length
    )
    print(
        "Request files:",
        list(request.files.keys())
    )
    print(
        "Request form:",
        list(request.form.keys())
    )
    print("=" * 60)

    file_path = None

    try:

        # ----------------------------------------------------
        # CHECK FILE
        # ----------------------------------------------------

        if "image" not in request.files:

            print(
                "ERROR: 'image' field not found."
            )

            return jsonify({
                "success": False,
                "error": "No image file provided."
            }), 400


        file = request.files["image"]


        # ----------------------------------------------------
        # PRINT FILE INFORMATION
        # ----------------------------------------------------

        print(
            "Filename:",
            repr(file.filename)
        )

        print(
            "Content-Type:",
            repr(file.content_type)
        )


        # ----------------------------------------------------
        # CHECK EMPTY FILE
        # ----------------------------------------------------

        if not file.filename:

            print(
                "ERROR: Empty filename."
            )

            return jsonify({
                "success": False,
                "error": "No image selected."
            }), 400


        # ----------------------------------------------------
        # CHECK IMAGE TYPE
        # ----------------------------------------------------

        if not allowed_file(file):

            print(
                "ERROR: Unsupported image type."
            )

            print(
                "Filename:",
                repr(file.filename)
            )

            print(
                "Content-Type:",
                repr(file.content_type)
            )

            return jsonify({
                "success": False,
                "error":
                    "Only JPG, JPEG, PNG and WebP images are allowed."
            }), 400


        # ----------------------------------------------------
        # READ FILE CONTENT
        # ----------------------------------------------------

        file.seek(0)

        file_data = file.read()

        print(
            "Uploaded file size:",
            len(file_data),
            "bytes"
        )


        # ----------------------------------------------------
        # CHECK EMPTY FILE
        # ----------------------------------------------------

        if not file_data:

            print(
                "ERROR: Uploaded image is empty."
            )

            return jsonify({
                "success": False,
                "error": "Uploaded image is empty."
            }), 400


        # ----------------------------------------------------
        # RESET FILE POSITION
        # ----------------------------------------------------

        file.seek(0)


        # ----------------------------------------------------
        # CREATE UNIQUE FILE NAME
        # ----------------------------------------------------

        extension = get_extension(file)

        filename = (
            str(uuid.uuid4())
            + extension
        )


        file_path = os.path.join(
            UPLOAD_FOLDER,
            filename
        )


        print(
            "Saving uploaded image to:",
            file_path
        )


        # ----------------------------------------------------
        # SAVE IMAGE
        # ----------------------------------------------------

        file.save(
            file_path
        )


        # ----------------------------------------------------
        # CHECK THAT FILE WAS SAVED
        # ----------------------------------------------------

        if not os.path.exists(
            file_path
        ):

            print(
                "ERROR: File was not saved."
            )

            return jsonify({
                "success": False,
                "error":
                    "Unable to save uploaded image."
            }), 500


        # ----------------------------------------------------
        # CHECK SAVED FILE SIZE
        # ----------------------------------------------------

        saved_size = os.path.getsize(
            file_path
        )

        print(
            "Saved file size:",
            saved_size,
            "bytes"
        )


        if saved_size == 0:

            print(
                "ERROR: Saved image is empty."
            )

            return jsonify({
                "success": False,
                "error":
                    "Saved image is empty."
            }), 400


        # ----------------------------------------------------
        # GINGIVA-FOCUSED PREPROCESSING
        # ----------------------------------------------------

        print(
            "Preparing image..."
        )

        image = prepare_image_from_file(
            file_path
        )

        print(
            "Image preprocessing completed."
        )


        # ----------------------------------------------------
        # PREDICT DOPI
        # ----------------------------------------------------

        print(
            "Running DOPI prediction..."
        )

        result = predict_dopi(
            image
        )

        print(
            "Prediction completed:"
        )

        print(
            result
        )


        # ----------------------------------------------------
        # RETURN RESULT
        # ----------------------------------------------------

        return jsonify({

            "success": True,

            "message":
                "Image analyzed successfully.",

            "result":
                result

        }), 200


    except Exception as error:

        # ----------------------------------------------------
        # SERVER ERROR
        # ----------------------------------------------------

        print("=" * 60)

        print(
            "PREDICTION ERROR:",
            repr(error)
        )

        print("=" * 60)

        return jsonify({

            "success": False,

            "error":
                str(error)

        }), 500


    finally:

        # ----------------------------------------------------
        # DELETE TEMPORARY FILE
        # ----------------------------------------------------

        if file_path is not None:

            if os.path.exists(
                file_path
            ):

                try:

                    os.remove(
                        file_path
                    )

                    print(
                        "Temporary image deleted."
                    )

                except Exception as cleanup_error:

                    print(
                        "Cleanup error:",
                        repr(cleanup_error)
                    )