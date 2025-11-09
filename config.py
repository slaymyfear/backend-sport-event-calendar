"""Flask configuration for database connectivity."""

import os
from urllib.parse import quote_plus


def _build_default_uri() -> str:
    """Build a default MySQL connection string using environment variables.

    Using explicit components prevents credentials with special characters from
    breaking the URI when not URL-encoded.
    
    """

    user = os.getenv("MYSQL_USER", "root")
    password = quote_plus(os.getenv("MYSQL_PASSWORD", "1234567890"))
    host = os.getenv("MYSQL_HOST", "127.0.0.1")
    port = os.getenv("MYSQL_PORT", "3306")
    database = os.getenv("MYSQL_DATABASE", "multiplesportdatabase_schema")

    return f"mysql://{user}:{password}@{host}:{port}/{database}"


class Config:
    """Default configuration loaded by the Flask app."""

    SQLALCHEMY_DATABASE_URI = os.getenv("DATABASE_URI", _build_default_uri())
    SQLALCHEMY_TRACK_MODIFICATIONS = False


__all__ = ["Config"]

