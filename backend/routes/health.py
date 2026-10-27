# ============================================================
# MELANOSCAN AI - HEALTH ROUTE
# ============================================================

from flask import Blueprint


# ============================================================
# CREATE BLUEPRINT
# ============================================================

health_bp = Blueprint(
    "health",
    __name__
)


# ============================================================
# HEALTH CHECK
# ============================================================

@health_bp.route(
    "/health",
    methods=["GET"]
)
def health_check():

    return {
        "status": "ok",
        "message": "MelanoScan AI backend is running"
    }, 200
