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


