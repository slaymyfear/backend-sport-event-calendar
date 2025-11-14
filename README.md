# backend-sport-event-calendar
This project shows the on application of some core programming concepts through the development of a sports event calendar website.
Multi-Sport Event Calendar Management System
- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Project Architecture](#project-architecture)
- [Database Schema](#database-schema)
- [Installation & Setup](#installation--setup)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [API Endpoints](#api-endpoints)
- [Troubleshooting](#troubleshooting)
- [EER DIAGRAM](#EERDIAGRAM)

---

## Overview

I created this multi-sport calendar system as a comprehensive web application designed to help manage and display different sporting events across multiple sports, competitions, and seasons. It provides a backend with a modern, responsive frontend interface for viewing, filtering, and managing sports fixtures.

The system supports:
- Multiple sports (football, basketball, tennis, etc.)
- Various competitions within each sport
- Multiple seasons and phases per competition
- Team management with detailed information
- Venue tracking
- Event scheduling and status management

---

## Features
### Core Functionality
- ✅ Multi-sport event management (Football, Basketball, Tennis, etc.)
- ✅ Competition and season management
- ✅ Team and venue tracking
- ✅ Event scheduling with score tracking
- ✅ Match period support for detailed scoring
- ✅ Event status management (scheduled, in_progress, played)
- ✅ Advanced filtering by sport, competition, date, and status

### Frontend Features
- 📱 Responsive calendar interface
- 🔍 Real-time event filtering
- 🎯 Quick event creation form
- 📊 Event status badges
- 🎨 Modern gradient UI with Glassmorphism design

### Backend Features
- 🔌 RESTful API endpoints
- 🗄️ MySQL database with comprehensive schema
- 🔐 Foreign key constraints and data integrity
- 📦 SQLAlchemy ORM with proper relationship modeling

---

## Technology Stack

### Backend
- **Framework:** Flask 2.3.3
- **Database:** MySQL with SQLAlchemy ORM
- **Migrations:** Flask-Migrate
- **Environment:** Python 3.x with python-dotenv

### Frontend
- **Markup:** HTML5
- **Styling:** CSS3 (Flexbox, Grid, Gradients)
- **Scripting:** Vanilla JavaScript (ES6+)
- **Fonts:** Google Fonts (Inter)

### Dependencies
```
Flask==2.3.3
Flask-SQLAlchemy==3.0.5
Flask-Migrate==4.0.4
mysqlclient==2.2.7
Jinja2==3.1.2
Werkzeug==2.3.7
python-dotenv==1.0.0
```

---

## Project Architecture

### Database Schema
The system uses a normalized relational database with the following key tables:

```
sport
  └── competition
       └── competition_season (phase, stage_ordering)
            └── event (home/away teams, scores, venue)
                 ├── period (scores by period)
                 ├── match_card (yellow/red cards)
                 └── match_goal (goals by period)

team
  ├── player (with positions)
  ├── coach
  └── team_competition (participation tracking)

venue
  └── event (location reference)
```

### API Architecture
- **Blueprint-based routing** for modular endpoint organization
- **Query optimization** with aliased joins for efficient team lookups
- **Computed status** based on score presence and explicit status field
- **Serialization layer** for consistent JSON responses

---

## Key Assumptions & Decisions

### Database Decisions
1. **Score Tracking at Multiple Levels:**
   - Scores stored in both `event` (final score) and `period` (per-period breakdown)
   - System aggregates period scores if available
   - Decision: Allows flexibility for multi-period sports (football, basketball, etc.)

2. **Status Management:**
   - Events have explicit `status` field (scheduled, in_progress, played)
   - Status computed from score presence (if scores exist → "played")
   - Decision: Provides both explicit control and automatic inference

3. **Team Reference:**
   - `home_team_id` can be NULL (e.g., TBD teams in final rounds)
   - Away team is always required
   - Decision: Accommodates tournament scenarios with unknown opponents

4. **Stage Ordering:**
   - `stage_ordering` field tracks tournament progression
   - Decision: Enables proper sequencing of tournament rounds (qualifiers → group stage → knockout)

5. **Extended Team Information:**
   - Teams include `official_name`, `slug`, and `abbreviation` fields
   - Decision: Supports flexible team identification and URL-friendly slugs

6. **Match Events Tracking:**
   - Separate tables for `match_card` (yellow/red cards) and `match_goal` (goals)
   - Decision: Enables detailed match analytics and statistics

### Frontend Decisions
1. **Client-side Filtering:**
   - All filtering happens on fetched data (no server-side query params)
   - Decision: Simplifies API, allows instant filter switching

2. **Glassmorphism Design:**
   - Semi-transparent cards with backdrop blur
   - Decision: Modern aesthetic, reduces design complexity

3. **Empty State Handling:**
   - Shows helpful message when no events match filters
   - Decision: Improves UX when no results found

4. **Score Display:**
   - Shows "1 - 2" format when both scores present
   - Shows NULL when scores unavailable
   - Decision: Clear visual distinction between scheduled and completed events

### Data Population
- SQL script provided for initial data seeding
- Duplicate event handling with safe cleanup procedures
- Decision: Allows multiple environments with consistent initial state

---

## Installation & Setup

### Prerequisites
- Python 3.8+
- MySQL 5.7+
- Git
- MySQL CLI access (for running SQL scripts)

### Step 1: Clone Repository
```bash
(https://github.com/slaymyfear/backend-sport-event-calendar.git)
```

### Step 2: Create Virtual Environment
```bash
python -m venv venv
source venv/bin/activate  # On macOS/Linux
# or
venv\Scripts\activate  # On Windows
```

### Step 3: Install Dependencies
```bash
pip install -r requirements.txt
```

### Step 4: Configure Environment
Create a `.env` file in the project root:
```env
MYSQL_USER=root
MYSQL_PASSWORD=your_password
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_DATABASE=multiplesportdatabase_schema
FLASK_ENV=development
```

### Step 5: Initialize Database

#### 5a. Create Database Schema
```bash
mysql -u root -p < setup_database.sql
```
This creates the complete database with all tables, relationships, and constraints.

#### 5b. Populate Database with Initial Data
```bash
mysql -u root -p < populate_database.sql
```
This inserts initial sports, teams, competitions, seasons, and events.

**Quick Setup (Run Both at Once):**
```bash
mysql -u root -p < setup_database.sql && mysql -u root -p < populate_database.sql
```

### Step 6: Run Flask Application
```bash
python run.py
```

The application will start on `http://localhost:5000`

### Step 7: Access the Application
- **Frontend:** http://localhost:5000
- **Admin Console:** http://localhost:5000/admin
- **API:** http://localhost:5000/events

---

## Usage

### Viewing Events
1. Navigate to http://localhost:5000
2. Browse all upcoming and completed events
3. Use filters to narrow down by:
   - Sport
   - Competition
   - Date
   - Status (Scheduled/In Progress/Completed)

### Creating Events
1. Click "Add Event" button
2. Fill in required fields:
   - Competition Season ID
   - Event Date
   - Home Team ID
   - Away Team ID
3. Optional fields:
   - Start Time
   - Venue ID
   - Status
4. Click "Save Event"

### Admin Interface
Access the admin console at `/admin` to:
- Create events with form validation
- View complete event registry
- Search by team or competition
- Delete events
- Refresh event list

---

## Project Structure

```
backend-sport-event-calendar/
├── backend/
│   ├── __init__.py                      # Flask extensions
│   ├── app.py                           # Application factory
│   ├── config.py                        # Configuration settings
│   ├── models.py                        # SQLAlchemy ORM models
│   ├── routes.py                        # Flask blueprints & endpoints
│   ├── static/
│   │   └── CALENDAR/
│   │       ├── app.js                   # Frontend JavaScript
│   │       └── styles.css               # Frontend styles
│   └── templates/
│       ├── calendar.html                # Main calendar interface
│       ├── admin.html                   # Admin dashboard
│       └── events.html                  # Events template
├── calendar/                             # Static calendar files
│   ├── index.html
│   ├── app.js
│   └── styles.css
├── run.py                               # Entry point
├── requirements.txt                     # Python dependencies
├── setup_database.sql                   # Complete database schema
├── populate_database.sql                # Initial data population
└── README.md                            # This file
```

---

## API Endpoints

### Events API (`/events`)

#### List All Events
```http
GET /events
```
Returns all events with complete details, relationships, and computed status.

**Response:**
```json
[
  {
    "event_id": 1,
    "event_date": "2025-11-03",
    "start_time": "00:00",
    "status": "played",
    "home_score": 1,
    "away_score": 2,
    "score": "1 - 2",
    "home_team": {
      "team_id": 1,
      "name": "Al Shabab FC",
      "country": "KSA"
    },
    "away_team": {
      "team_id": 2,
      "name": "FC Nasaf",
      "country": "UZB"
    },
    "competition": {
      "name": "AFC Champions League",
      "phase": "ROUND OF 16"
    }
  }
]
```

#### Get Single Event
```http
GET /events/<event_id>
```

#### Create Event
```http
POST /events
Content-Type: application/json

{
  "competition_season_id": 1,
  "event_date": "2025-11-03",
  "start_time": "16:00:00",
  "home_team_id": 1,
  "away_team_id": 2,
  "venue_id": 1,
  "status": "scheduled"
}
```

#### Delete Event
```http
DELETE /events/<event_id>
```

---

## Troubleshooting

### Database Connection Issues
- Ensure MySQL is running: `mysql.server status`
- Verify credentials in `.env` file
- Check database name: `multiplesportdatabase_schema`

### Schema Setup Fails
Check if database exists:
```bash
mysql -u root -p -e "SHOW DATABASES;"
```

### Missing Tables After Population
Ensure both scripts ran successfully:
```bash
mysql -u root -p -e "USE multiplesportdatabase_schema; SHOW TABLES;"
```

### Port Already in Use
Flask runs on port 5000 by default. Change in `run.py`:
```python
app.run(host="0.0.0.0", port=8000, debug=True)
```

### Resetting the Database
To completely reset and rebuild:
```bash
mysql -u root -p -e "DROP DATABASE IF EXISTS multiplesportdatabase_schema;"
mysql -u root -p < setup_database.sql
mysql -u root -p < populate_database.sql
```

---

## Future Enhancements

- [ ] WebSocket support for live score updates
- [ ] User authentication and authorization
- [ ] Advanced analytics dashboard
- [ ] Mobile app (React Native)
- [ ] Email notifications for event updates
- [ ] Player statistics tracking
- [ ] Team rankings and standings
- [ ] Match predictions API

##EER DIAGRAM
<img width="1611" height="1241" alt="eer diagram" src="https://github.com/user-attachments/assets/d93978a4-31b5-42f1-8106-e6aaa9d64060" />

---
