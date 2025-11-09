"""Backend application factory and extensions."""

from flask import Flask, render_template
from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy
from dotenv import load_dotenv

db = SQLAlchemy()
migrate = Migrate()


def create_app() -> Flask:
    """Application factory configured for the multi-sport database."""

    load_dotenv()

    app = Flask(__name__)
    app.config.from_object("backend.config.Config")

    db.init_app(app)
    migrate.init_app(app, db)

    from backend.routes import events_bp  # pylint: disable=import-outside-toplevel

    app.register_blueprint(events_bp, url_prefix="/events")

    @app.route("/")
    def index():
        return render_template("calendar.html")

    return app


__all__ = ["create_app", "db", "migrate"]

