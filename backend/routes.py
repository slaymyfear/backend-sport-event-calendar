"""Database models for event management endpoints."""

from __future__ import annotations

from datetime import date, datetime, time
from typing import Dict, Optional

from sqlalchemy import (
    CheckConstraint,
    Date,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Time,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from backend import db


class Sport(db.Model):
    __tablename__ = "sport"

    sport_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False, unique=True)

    def to_reference(self) -> Dict[str, Optional[str]]:
        return {"sport_id": self.sport_id, "name": self.name}


class Competition(db.Model):
    __tablename__ = "competition"

    competition_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    sport_id: Mapped[int] = mapped_column(ForeignKey("sport.sport_id"), nullable=False)
    description: Mapped[Optional[str]] = mapped_column(String(500))
    external_id: Mapped[Optional[str]] = mapped_column(String(100))

    sport: Mapped[Sport] = relationship(Sport, lazy="joined")

    def to_reference(self) -> Dict[str, Optional[str]]:
        return {
            "competition_id": self.competition_id,
            "name": self.name,
            "description": self.description,
        }


class Team(db.Model):
    __tablename__ = "team"

    team_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    official_name: Mapped[Optional[str]] = mapped_column(String(200))
    slug: Mapped[Optional[str]] = mapped_column(String(200))
    abbreviation: Mapped[Optional[str]] = mapped_column(String(10))
    logo_url: Mapped[Optional[str]] = mapped_column(String(500))
    city: Mapped[Optional[str]] = mapped_column(String(100))
    country: Mapped[Optional[str]] = mapped_column(String(100))
    founded_year: Mapped[Optional[int]] = mapped_column(Integer)

    def to_reference(self) -> Dict[str, Optional[str]]:
        return {
            "team_id": self.team_id,
            "name": self.name,
            "city": self.city,
            "country": self.country,
        }


class CompetitionSeason(db.Model):
    __tablename__ = "competition_season"

    competition_season_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    competition_id: Mapped[int] = mapped_column(
        ForeignKey("competition.competition_id"), nullable=False
    )
    season_id: Mapped[int] = mapped_column(Integer, nullable=False)
    phase: Mapped[str] = mapped_column(String(100), nullable=False)
    stage_ordering: Mapped[Optional[int]] = mapped_column(Integer)
    ruleset_id: Mapped[Optional[int]] = mapped_column(Integer)

    competition: Mapped[Competition] = relationship(Competition, lazy="joined")


class Venue(db.Model):
    __tablename__ = "venue"

    venue_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(200), nullable=False)
    city: Mapped[Optional[str]] = mapped_column(String(100))
    country: Mapped[Optional[str]] = mapped_column(String(100))
    capacity: Mapped[Optional[int]] = mapped_column(Integer)


class Event(db.Model):
    __tablename__ = "event"
    __table_args__ = (
        CheckConstraint("home_team_id <> away_team_id", name="chk_event_teams"),
    )

    event_id: Mapped[int] = mapped_column(Integer, primary_key=True)
    competition_season_id: Mapped[int] = mapped_column(
        ForeignKey("competition_season.competition_season_id"), nullable=False
    )
    event_date: Mapped[date] = mapped_column(Date, nullable=False)
    start_time: Mapped[Optional[time]] = mapped_column(Time)
    home_team_id: Mapped[int] = mapped_column(
        ForeignKey("team.team_id"), nullable=False
    )
    away_team_id: Mapped[int] = mapped_column(
        ForeignKey("team.team_id"), nullable=False
    )
    venue_id: Mapped[Optional[int]] = mapped_column(ForeignKey("venue.venue_id"))
    status: Mapped[str] = mapped_column(String(50), default="scheduled", nullable=False)
    home_score: Mapped[Optional[int]] = mapped_column(Integer)
    away_score: Mapped[Optional[int]] = mapped_column(Integer)

    home_team: Mapped[Team] = relationship(
        Team,
        foreign_keys=[home_team_id],
        lazy="joined",
    )
    away_team: Mapped[Team] = relationship(
        Team,
        foreign_keys=[away_team_id],
        lazy="joined",
    )
    competition_season: Mapped[CompetitionSeason] = relationship(
        CompetitionSeason, foreign_keys=[competition_season_id], lazy="joined"
    )
    venue: Mapped[Optional[Venue]] = relationship(
        Venue, foreign_keys=[venue_id], lazy="joined"
    )

    def serialize(self) -> Dict[str, Optional[str]]:
        """Return a JSON-friendly representation of an event."""

        def _format_date(value: Optional[date]) -> Optional[str]:
            return value.isoformat() if value else None

        def _format_time(value: Optional[time]) -> Optional[str]:
            return value.isoformat(timespec="minutes") if value else None

        def _format_datetime(value: Optional[datetime]) -> Optional[str]:
            return value.isoformat() if value else None

        payload = {
            "event_id": self.event_id,
            "competition_season_id": self.competition_season_id,
            "event_date": _format_date(self.event_date),
            "start_time": _format_time(self.start_time),
            "status": self.status,
            "home_score": self.home_score,
            "away_score": self.away_score,
            "score": (
                f"{self.home_score} - {self.away_score}"
                if self.home_score is not None and self.away_score is not None
                else None
            ),
            "home_team": self.home_team.to_reference() if self.home_team else None,
            "away_team": self.away_team.to_reference() if self.away_team else None,
            "venue": {
                "venue_id": self.venue.venue_id,
                "name": self.venue.name,
                "city": self.venue.city,
                "country": self.venue.country,
            }
            if self.venue
            else None,
        }

        competition = (
            self.competition_season.competition if self.competition_season else None
        )
        if competition:
            payload["competition"] = competition.to_reference()
            payload["competition"]["phase"] = self.competition_season.phase
            payload["competition"]["season_id"] = self.competition_season.season_id
            payload["sport"] = (
                competition.sport.to_reference() if competition.sport else None
            )

        return payload


__all__ = ["Competition", "CompetitionSeason", "Event", "Sport", "Team", "Venue"]

