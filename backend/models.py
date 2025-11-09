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


