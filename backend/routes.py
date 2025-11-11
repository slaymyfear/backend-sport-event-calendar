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
    home_score = payload.get("home_score")
    away_score = payload.get("away_score")

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
        home_score=int(home_score) if home_score is not None else None,
        away_score=int(away_score) if away_score is not None else None,
    )

    db.session.add(event)

    try:
        db.session.commit()
    except IntegrityError as exc:
        db.session.rollback()
        return (
            jsonify({"error": "Failed to create event", "details": str(exc.orig)}),
            400,
        )

    fresh_event = Event.query.filter_by(event_id=event.event_id).first()

    return jsonify(fresh_event.serialize() if fresh_event else event.serialize()), 201


@events_bp.get("")
def list_events():
    home_team = aliased(Team)
    away_team = aliased(Team)

    query = (
        db.session.query(
            Event.event_id,
            Event.competition_season_id,
            Event.event_date,
            Event.start_time,
            Event.status,
            Event.home_score,
            Event.away_score,
            CompetitionSeason.phase,
            CompetitionSeason.stage_ordering,
            CompetitionSeason.season_id,
            Competition.competition_id,
            Competition.name.label("competition_name"),
            Sport.sport_id,
            Sport.name.label("sport_name"),
            home_team.team_id.label("home_team_id"),
            home_team.name.label("home_team_name"),
            home_team.official_name.label("home_team_official_name"),
            home_team.slug.label("home_team_slug"),
            home_team.abbreviation.label("home_team_abbreviation"),
            home_team.country.label("home_team_country"),
            away_team.team_id.label("away_team_id"),
            away_team.name.label("away_team_name"),
            away_team.official_name.label("away_team_official_name"),
            away_team.slug.label("away_team_slug"),
            away_team.abbreviation.label("away_team_abbreviation"),
            away_team.country.label("away_team_country"),
            Venue.venue_id,
            Venue.name.label("venue_name"),
            Venue.city.label("venue_city"),
        )
        .join(home_team, Event.home_team_id == home_team.team_id, isouter=True)
        .join(away_team, Event.away_team_id == away_team.team_id)
        .join(
            CompetitionSeason,
            Event.competition_season_id == CompetitionSeason.competition_season_id,
        )
        .join(Competition, CompetitionSeason.competition_id == Competition.competition_id)
        .join(Sport, Competition.sport_id == Sport.sport_id)
        .outerjoin(Venue, Event.venue_id == Venue.venue_id)
        .order_by(Event.event_date, Event.start_time)
    )

    events = []
    for row in query.all():
        # Determine display status:
        # - If scores present, it's played
        # - Otherwise show scheduled (even if date is in the past as requested)
        has_scores = (
            getattr(row, "home_score", None) is not None
            and getattr(row, "away_score", None) is not None
        )
        # Prefer the explicitly stored status when available
        if row.status and row.status.lower() == "played":
            computed_status = "played"
        elif has_scores:
            computed_status = "played"
        else:
            computed_status = "scheduled"

        event_dict = {
            "event_id": row.event_id,
            "competition_season_id": row.competition_season_id,
            "event_date": row.event_date.isoformat(),
            "start_time": row.start_time.isoformat() if row.start_time else None,
            "status": computed_status,
            "home_score": getattr(row, "home_score", None),
            "away_score": getattr(row, "away_score", None),
            "score": (
                f"{row.home_score} - {row.away_score}"
                if has_scores
                else None
            ),
            "home_team": {
                "team_id": row.home_team_id,
                "name": row.home_team_name,
                "official_name": row.home_team_official_name,
                "slug": row.home_team_slug,
                "abbreviation": row.home_team_abbreviation,
                "country": row.home_team_country,
            } if row.home_team_name else None,
            "away_team": {
                "team_id": row.away_team_id,
                "name": row.away_team_name,
                "official_name": row.away_team_official_name,
                "slug": row.away_team_slug,
                "abbreviation": row.away_team_abbreviation,
                "country": row.away_team_country,
            } if row.away_team_name else None,
            "venue": {
                "venue_id": row.venue_id,
                "name": row.venue_name,
                "city": row.venue_city,
            } if row.venue_name else None,
            "competition": {
                "competition_id": row.competition_id,
                "name": row.competition_name,
                "phase": row.phase,
                "season_id": row.season_id,
            },
            "sport": {
                "sport_id": row.sport_id,
                "name": row.sport_name,
            },
        }
        events.append(event_dict)

    return jsonify(events)


@events_bp.get("/<int:event_id>")
def get_event(event_id: int):
    event = Event.query.filter_by(event_id=event_id).first()
    if event is None:
        return jsonify({"error": "Event not found"}), 404

    return jsonify(event.serialize())


@events_bp.delete("/<int:event_id>")
def delete_event(event_id: int):
    event = Event.query.filter_by(event_id=event_id).first()
    if event is None:
        return jsonify({"error": "Event not found"}), 404

    db.session.delete(event)
    db.session.commit()

    return jsonify({"message": "Event deleted"})

