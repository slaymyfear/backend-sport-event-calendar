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


def _parse_date(value: str) -> date:
    try:
        return date.fromisoformat(value)
    except ValueError as exc:  # pragma: no cover - defensive path
        raise ValueError("event_date must be in ISO format YYYY-MM-DD") from exc


def _parse_time(value: Optional[str]) -> Optional[time]:
    if value in (None, ""):
        return None
    try:
        return time.fromisoformat(value)
    except ValueError as exc:  # pragma: no cover - defensive path
        raise ValueError("start_time must be in ISO format HH:MM[:SS]") from exc


@events_bp.post("")
def create_event():
    payload: Dict[str, Any] = request.get_json(force=True)

    required_fields = [
        "competition_season_id",
        "event_date",
        "home_team_id",
        "away_team_id",
    ]

    missing = [field for field in required_fields if field not in payload]
    if missing:
        return jsonify({"error": f"Missing required fields: {', '.join(missing)}"}), 400

    competition_season_id = int(payload["competition_season_id"])
    event_date = _parse_date(str(payload["event_date"]))
    start_time = _parse_time(payload.get("start_time"))
    home_team_id = int(payload["home_team_id"])
    away_team_id = int(payload["away_team_id"])
    venue_id = payload.get("venue_id")
    status = payload.get("status", "scheduled")

    if home_team_id == away_team_id:
        return jsonify({"error": "home_team_id and away_team_id must differ"}), 400

    event = Event(
        competition_season_id=competition_season_id,
        event_date=event_date,
        start_time=start_time,
        home_team_id=home_team_id,
        away_team_id=away_team_id,
        venue_id=int(venue_id) if venue_id is not None else None,
        status=status,
    )
