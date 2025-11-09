"""Flask blueprints for event operations."""

from __future__ import annotations

from datetime import date, time
from typing import Any, Dict, Optional

from flask import Blueprint, jsonify, request
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import aliased

from backend import db
from backend.models import (
    Competition,
    CompetitionSeason,
    Event,
    Sport,
    Team,
    Venue,
)

events_bp = Blueprint("events", __name__)
