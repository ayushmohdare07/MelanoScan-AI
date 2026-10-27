# ============================================================
# MELANOSCAN AI - GINGIVA IMAGE PROCESSING
# ============================================================

import cv2
import numpy as np


# ============================================================
# MODEL IMAGE SIZE
# ============================================================

IMAGE_SIZE = 224


# ============================================================
# LOAD IMAGE
# ============================================================

def load_image(
    image_path
):

    image = cv2.imread(
        image_path
    )


    if image is None:

        raise ValueError(
            "Unable to read image: "
            + image_path
        )


    return image


# ============================================================
# FIND GINGIVA REGION
# ============================================================

def find_gingiva_roi(
    image
):

    height, width = image.shape[:2]


    # --------------------------------------------------------
    # Convert image to HSV
    # --------------------------------------------------------

    hsv = cv2.cvtColor(
        image,
        cv2.COLOR_BGR2HSV
    )


    # --------------------------------------------------------
    # HSV channels
    # --------------------------------------------------------

    h = hsv[:, :, 0]
    s = hsv[:, :, 1]
    v = hsv[:, :, 2]


    # --------------------------------------------------------
    # Detect reddish / pink tissue
    # --------------------------------------------------------

    mask1 = cv2.inRange(
        hsv,
        np.array([0, 25, 35]),
        np.array([15, 255, 255])
    )


    mask2 = cv2.inRange(
        hsv,
        np.array([160, 25, 35]),
        np.array([179, 255, 255])
    )


    gingiva_mask = cv2.bitwise_or(
        mask1,
        mask2
    )


    # --------------------------------------------------------
    # Remove very dark regions
    # --------------------------------------------------------

    dark_mask = (
        v < 30
    ).astype(
        np.uint8
    ) * 255


    gingiva_mask = cv2.bitwise_and(
        gingiva_mask,
        cv2.bitwise_not(
            dark_mask
        )
    )


    # --------------------------------------------------------
    # Morphological cleanup
    # --------------------------------------------------------

    kernel = cv2.getStructuringElement(
        cv2.MORPH_ELLIPSE,
        (9, 9)
    )


    gingiva_mask = cv2.morphologyEx(
        gingiva_mask,
        cv2.MORPH_CLOSE,
        kernel
    )


    gingiva_mask = cv2.morphologyEx(
        gingiva_mask,
        cv2.MORPH_OPEN,
        kernel
    )


    # --------------------------------------------------------
    # Find connected regions
    # --------------------------------------------------------

    contours, _ = cv2.findContours(
        gingiva_mask,
        cv2.RETR_EXTERNAL,
        cv2.CHAIN_APPROX_SIMPLE
    )


    # --------------------------------------------------------
    # If no useful region is found
    # --------------------------------------------------------

    if not contours:

        return center_crop(
            image
        )


    # --------------------------------------------------------
    # Select useful contours
    # --------------------------------------------------------

    min_area = (
        width *
        height *
        0.005
    )


    valid_contours = []


    for contour in contours:

        area = cv2.contourArea(
            contour
        )


        if area >= min_area:

            valid_contours.append(
                contour
            )


    if not valid_contours:

        return center_crop(
            image
        )


    # --------------------------------------------------------
    # Combine useful contours
    # --------------------------------------------------------

    all_points = np.vstack(
        valid_contours
    )


    x, y, w, h = cv2.boundingRect(
        all_points
    )


    # --------------------------------------------------------
    # Ignore extremely small boxes
    # --------------------------------------------------------

    if (
        w < width * 0.15
        or
        h < height * 0.05
    ):

        return center_crop(
            image
        )


    # --------------------------------------------------------
    # Add padding
    # --------------------------------------------------------

    padding_x = max(
        10,
        int(w * 0.20)
    )


    padding_y = max(
        10,
        int(h * 0.30)
    )


    x1 = max(
        0,
        x - padding_x
    )


    y1 = max(
        0,
        y - padding_y
    )


    x2 = min(
        width,
        x + w + padding_x
    )


    y2 = min(
        height,
        y + h + padding_y
    )


    roi = image[
        y1:y2,
        x1:x2
    ]


    if roi.size == 0:

        return center_crop(
            image
        )


    return roi


# ============================================================
# FALLBACK CENTER CROP
# ============================================================

def center_crop(
    image
):

    height, width = image.shape[:2]


    crop_width = int(
        width * 0.80
    )


    crop_height = int(
        height * 0.60
    )


    x1 = max(
        0,
        (width - crop_width) // 2
    )


    y1 = max(
        0,
        (height - crop_height) // 2
    )


    x2 = min(
        width,
        x1 + crop_width
    )


    y2 = min(
        height,
        y1 + crop_height
    )


    return image[
        y1:y2,
        x1:x2
    ]


# ============================================================
# PREPARE GINGIVA IMAGE
# ============================================================

def prepare_image(
    image
):

    # --------------------------------------------------------
    # Find gingiva region
    # --------------------------------------------------------

    roi = find_gingiva_roi(
        image
    )


    # --------------------------------------------------------
    # Resize
    # --------------------------------------------------------

    roi = cv2.resize(
        roi,
        (
            IMAGE_SIZE,
            IMAGE_SIZE
        ),
        interpolation=cv2.INTER_AREA
    )


    # --------------------------------------------------------
    # BGR → RGB
    # --------------------------------------------------------

    roi = cv2.cvtColor(
        roi,
        cv2.COLOR_BGR2RGB
    )


    # --------------------------------------------------------
    # Float32
    # --------------------------------------------------------

    roi = roi.astype(
        np.float32
    )


    return roi


# ============================================================
# PREPARE IMAGE FROM FILE
# ============================================================

def prepare_image_from_file(
    image_path
):

    image = load_image(
        image_path
    )


    roi = prepare_image(
        image
    )


    return roi


print(
    "Gingiva image processing module loaded."
)