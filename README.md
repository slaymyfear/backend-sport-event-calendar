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
- [EER DIAGRAM](#EER-DIAGRAM)

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

### User-Facing Features

- 📅 **Event Calendar View**: Visual display of all upcoming sporting events
- 🔍 **Advanced Filtering**: Filter events by:
  - Sport type
  - Competition
  - Date range
  - Event status (scheduled, in progress, completed)
- ➕ **Event Creation**: Add new events directly from the web interface
- 📊 **Event Details**: View comprehensive information including:
  - Teams (home and away)
  - Venue information
  - Competition and season details
  - Event status and timing
  - Scores (both event-level and period-aggregated)
- 📈 **Score Display**: Automatic score resolution from event scores or period aggregation

### Technical Features

- 🔐 **Data Integrity**: Database constraints ensure data consistency
- 🚀 **Performance**: Optimized queries with eager loading of relationships
- 📱 **Responsive Design**: Works seamlessly on desktop, tablet, and mobile devices
- 🎨 **Modern UI**: Clean, intuitive interface with smooth animations
- 🔄 **Score Aggregation**: Intelligent score resolution from period-level data when event scores are missing

---

## 🛠️ Technology Stack

### Backend

- **Flask 2.3.3**: Lightweight Python web framework
  - *Why*: Provides flexibility, extensibility, and a simple routing system
- **SQLAlchemy 3.0.5**: Python ORM (Object-Relational Mapping)
  - *Why*: Abstracts database operations, provides type safety, and enables database-agnostic code
- **Flask-SQLAlchemy 3.0.5**: Flask extension for SQLAlchemy integration
  - *Why*: Simplifies database initialization and session management in Flask apps
- **Flask-Migrate 4.0.4**: Database migration tool
  - *Why*: Enables version control for database schema changes
- **mysqlclient 2.2.7**: MySQL database connector
  - *Why*: High-performance Python interface to MySQL database
- **python-dotenv 1.0.0**: Environment variable management
  - *Why*: Secure handling of database credentials and configuration

### Frontend

- **HTML5**: Semantic markup for structure
- **CSS3**: Modern styling with:
  - CSS Grid and Flexbox for layouts
  - CSS Variables for theming
  - Responsive design principles
- **Vanilla JavaScript (ES6+)**: No framework dependencies
  - *Why*: Lightweight, fast, and maintainable without external dependencies
  - Features: Async/await, Fetch API, DOM manipulation

### Database

- **MySQL**: Relational database management system
  - *Why*: Robust, widely-used, excellent for complex relational data
  - Supports foreign keys, constraints, and transactions
  - Version: MySQL 5.7+ or MariaDB equivalent

### Development Tools

- **Jinja2 3.1.2**: Template engine for Flask
- **Werkzeug 2.3.7**: WSGI utility library (Flask dependency)
- **Python 3.8+**: Required Python version

---

## 🏗️ Project Architecture

### Application Factory Pattern

The project uses Flask's application factory pattern, which provides:
- **Modularity**: Easy to test and configure
- **Flexibility**: Multiple app instances with different configurations
- **Scalability**: Clean separation of concerns

### Structure Overview

```
┌─────────────────────────────────────────┐
│         Frontend (Browser)               │
│  ┌──────────────┐  ┌──────────────┐    │
│  │ calendar.html│  │  admin.html  │    │
│  │  (User View)  │  │ (Admin View) │    │
│  └──────┬───────┘  └──────┬───────┘    │
│         │                  │            │
│         └────────┬─────────┘            │
│                  │ HTTP/REST API        │
└──────────────────┼──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│      Flask Application (Backend)       │
│  ┌──────────────────────────────────┐  │
│  │     Routes (routes.py)           │  │
│  │  - GET /events                   │  │
│  │  - GET /events/<id>               │  │
│  │  - POST /events                  │  │
│  │  - PATCH /events/<id>             │  │
│  │  - DELETE /events/<id>            │  │
│  └──────────────┬───────────────────┘  │
│                 │                       │
│  ┌──────────────▼───────────────────┐  │
│  │     Models (models.py)            │  │
│  │  - Event, Team, Sport, etc.       │  │
│  └──────────────┬───────────────────┘  │
│                 │                       │
│  ┌──────────────▼───────────────────┐  │
│  │  SQLAlchemy ORM                   │  │
│  └──────────────┬───────────────────┘  │
└─────────────────┼──────────────────────┘
                  │
┌─────────────────▼──────────────────────┐
│         MySQL Database                  │
│  - Sport, Competition, Team, Event,    │
│    Venue, CompetitionSeason, Period    │
│    and more tables                     │
└─────────────────────────────────────────┘
```

### Request Flow

1. **User Action**: User interacts with frontend (clicks button, submits form)
2. **API Call**: JavaScript makes HTTP request to Flask backend
3. **Route Handler**: Flask route processes request, validates data
4. **Database Query**: SQLAlchemy queries/updates database with optimized joins
5. **Score Resolution**: System resolves scores from event or aggregated periods
6. **Response**: JSON data returned to frontend
7. **UI Update**: JavaScript updates DOM with new data

### Key Architectural Decisions

- **Application Factory**: Allows for testing and multiple configurations
- **Blueprint Pattern**: Routes organized in blueprints for modularity
- **Eager Loading**: Relationships loaded with `lazy="joined"` to prevent N+1 queries
- **Type Hints**: Python type hints throughout for better code clarity
- **Separation of Concerns**: Models, routes, and configuration in separate files

---

## 🗄️ Database Schema

### Entity Relationship Overview

The database follows a normalized design with the following key entities:

```
Sport (1) ────< (Many) Competition
                │
                └───< (Many) CompetitionSeason
                         │
                         └───< (Many) Event
                                    │
                    ┌───────────────┼───────────────┐
                    │               │               │
              (Many) Team      (Many) Team      (1) Venue
              (home_team)    (away_team)
                    │
                    └───< (Many) Period
                              │
                              └─── (Aggregates scores)
```

### Core Tables

#### 1. **sport**
- Represents a sport type (e.g., Football, Basketball, Tennis)
- Fields: `sport_id` (PK), `name` (UNIQUE)
- Base entity for all sports-related data

#### 2. **competition**
- Represents a league or tournament within a sport
- Fields: `competition_id` (PK), `name`, `sport_id` (FK), `description`, `external_id`
- Unique constraint on `(name, sport_id)`
- Foreign key to `sport`

#### 3. **team**
- Represents a sports team
- Fields: `team_id` (PK), `name`, `official_name`, `slug`, `abbreviation`, `logo_url`, `city`, `country`, `founded_year`
- Unique constraint on `(name, city, country)`
- Can participate in multiple events

#### 4. **season**
- Represents a season (e.g., "2024-25")
- Fields: `season_id` (PK), `name` (UNIQUE), `start_date`, `end_date`
- Check constraint ensures `start_date < end_date`

#### 5. **competition_season**
- Links competitions to specific seasons and phases
- Fields: `competition_season_id` (PK), `competition_id` (FK), `season_id` (FK), `phase`, `ruleset_id` (FK), `stage_ordering`
- Unique constraint on `(competition_id, season_id, phase)`
- Enables tracking of different phases (regular season, playoffs, etc.)
- Supports cascade delete for data integrity

#### 6. **venue**
- Represents a location where events occur
- Fields: `venue_id` (PK), `name`, `city`, `country`, `capacity`
- Optional for events (events can be scheduled without a venue)

#### 7. **event**
- Core entity representing a sporting match/fixture
- Fields:
  - `event_id` (PK): Primary key
  - `competition_season_id` (FK): Links to competition and season
  - `event_date`: Date of the event (required)
  - `start_time`: Optional start time
  - `home_team_id` (FK): Home team reference
  - `away_team_id` (FK): Away team reference
  - `venue_id` (FK): Optional venue reference
  - `status`: Event status (scheduled, in_progress, played, etc.)
  - `home_score`: Final home team score (optional)
  - `away_score`: Final away team score (optional)
- **Constraint**: `home_team_id` and `away_team_id` must be different (check constraint)
- Foreign keys to `Team` (twice), `CompetitionSeason`, and `Venue`
- Supports cascade delete with competition_season

#### 8. **period**
- Represents individual periods/quarters/halves of an event
- Fields: `period_id` (PK), `event_id` (FK), `ruleset_id` (FK), `period_number`, `start_timestamp`, `end_timestamp`, `home_score`, `away_score` (default 0)
- Foreign key to `event` with cascade delete
- Scores from periods can be aggregated to event-level scores

#### 9. **Additional Supporting Tables**
- **ruleset**: Sport-specific rules (number of periods, duration, scoring rules)
- **player**: Player information and statistics
- **coach**: Coach information and statistics
- **position**: Sport-specific positions
- **event_lineup**: Team lineups for events
- **lineup_player**: Players in specific lineups
- **score**: Detailed scoring information
- **score_type**: Types of scores (goal, point, etc.)
- **player_event_stats**: Player statistics per event
- **player_season_stats**: Player statistics per season
- **team_season_stats**: Team statistics per season
- **team_form**: Team recent form data
- **team_competition**: Many-to-many relationship between teams and competitions
- **player_team_history**: Historical player-team associations

### Database Design Decisions

1. **Normalization**: Data is normalized to reduce redundancy and ensure consistency
2. **Foreign Keys**: Enforce referential integrity at the database level
3. **Check Constraints**: Prevent invalid data (e.g., same team for home and away)
4. **Optional Fields**: Many fields are nullable to support partial data entry
5. **Cascade Deletes**: Appropriate cascade rules for maintaining referential integrity
6. **Score Aggregation**: Event scores take precedence, with period aggregation as fallback
7. **Unique Constraints**: Prevent duplicate teams, competitions, and season combinations

---

## 📦 Installation & Setup

### Prerequisites

- **Python 3.8** - Check with `python --version` or `python3 --version`
- **MySQL 5.7 or higher** (or MariaDB equivalent) - Check with `mysql --version`
- **pip** (Python package manager) - Usually comes with Python
- **Git** (optional, for cloning the repository)

### Step 1: Clone the Repository

```bash
git clone <https://github.com/slaymyfear/backend-sport-event-calendar.git>
cd project_work
```

Or if you already have the files, navigate to the project directory:

```bash
cd project_work
```

### Step 2: Set Up Virtual Environment

Create and activate a virtual environment to isolate project dependencies:

```bash
# Create virtual environment
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate

# On macOS/Linux:
source venv/bin/activate
```

You should see `(venv)` prefix in your terminal prompt when activated.

### Step 3: Install Dependencies

Install all required Python packages:

```bash
pip install -r requirements.txt
```

This will install:
- Flask and related extensions
- SQLAlchemy and Flask-SQLAlchemy
- MySQL client library
- Other dependencies

### Step 4: Database Setup

#### Option A: Use Existing SQL Script (Recommended for Quick Start)

```bash
# Import the database schema
mysql -u root -p < bettermysqldatabase.sql
```

When prompted, enter your MySQL root password. This will:
- Create the database `multiplesportdatabase_schema`
- Create all required tables
- Set up foreign keys and constraints

#### Option B: Use Flask-Migrate (Recommended for Development)

```bash
# Set Flask app environment variable
# On Windows:
set FLASK_APP=run.py

# On macOS/Linux:
export FLASK_APP=run.py

# Initialize migrations
flask db init

# Create initial migration
flask db migrate -m "Initial migration"

# Apply migration
flask db upgrade
```

### Step 5: Configure Environment Variables

Create a `.env` file in the project root directory:

```env
# Database Configuration
MYSQL_USER=root
MYSQL_PASSWORD=your_password_here
MYSQL_HOST=127.0.0.1
MYSQL_PORT=3306
MYSQL_DATABASE=multiplesportdatabase_schema

# Or use a complete connection string (alternative)
# DATABASE_URI=mysql://user:password@host:port/database
```

**Important Security Notes**:
- Never commit `.env` files to version control
- Add `.env` to `.gitignore`
- Use strong passwords in production
- Consider using environment-specific configurations

### Step 6: Populate Initial Data (Optional)

If you want to populate the database with sample data:

```bash
# Populate with sports data
mysql -u root -p multiplesportdatabase_schema < populate_withmultiple_sports.sql

# Or populate from API (if you have API access)
mysql -u root -p multiplesportdatabase_schema < populate_from_api.sql
```

### Step 7: Run the Application

Start the Flask development server:

```bash
python run.py
```

The application will start and be available at:
- **Main Application**: `http://localhost:5000`
- **API Endpoint**: `http://localhost:5000/events`

You should see output like:
```
 * Running on http://0.0.0.0:5000
 * Debug mode: on
```

### Step 8: Verify Installation

1. Open your browser and navigate to `http://localhost:5000`
2. You should see the Cakendar calendar interface
3. Test the API endpoint: `http://localhost:5000/events`
4. Try creating an event through the admin interface


## 🚀 Usage

### User Interface

#### Main Calendar View (`/`)

1. **View Events**: All events are displayed in a grid/list layout
2. **Filter Events**: Use the filters panel (if available):
   - Select a sport from the dropdown
   - Select a competition
   - Choose a specific date
   - Filter by status (scheduled, in progress, completed)
3. **Create Event**: Click "Add Event" button to open the creation form
4. **View Event Details**: Click on an event to see detailed information
5. **Clear Filters**: Click "Clear Filters" to reset all filters

### API Usage Examples

#### Get All Events

```bash
curl http://localhost:5000/events
```

#### Get Specific Event

```bash
curl http://localhost:5000/events/1
```

#### Create Event

```bash
curl -X POST http://localhost:5000/events \
  -H "Content-Type: application/json" \
  -d '{
    "competition_season_id": 1,
    "event_date": "2024-12-25",
    "start_time": "15:00",
    "home_team_id": 1,
    "away_team_id": 2,
    "venue_id": 1,
    "status": "scheduled"
  }'
```

#### Update Event (PATCH)

```bash
curl -X PATCH http://localhost:5000/events/1 \
  -H "Content-Type: application/json" \
  -d '{
    "home_score": 2,
    "away_score": 1,
    "status": "played"
  }'
```

#### Delete Event

```bash
curl -X DELETE http://localhost:5000/events/1
```

### Using Python Requests Library

```python
import requests

# Get all events
response = requests.get('http://localhost:5000/events')
events = response.json()

# Create an event
new_event = {
    "competition_season_id": 1,
    "event_date": "2024-12-25",
    "start_time": "15:00",
    "home_team_id": 1,
    "away_team_id": 2,
    "status": "scheduled"
}
response = requests.post('http://localhost:5000/events', json=new_event)
```

---

## 📁 Project Structure

```
project_work/
│
├── backend/                           # Backend application package
│   ├── __init__.py                    # Package initialization
│   ├── app.py                         # Flask application factory
│   ├── config.py                      # Configuration management
│   ├── models.py                      # SQLAlchemy database models
│   ├── routes.py                      # API route handlers (blueprint)
│   │
│   ├── static/                        # Static files (CSS, JavaScript, images)
│   │   ├── calendar/                  # Calendar frontend assets
│   │   │   ├── app.js                 # Frontend JavaScript logic
│   │   │   └── styles.css             # Application styles
│   │   └── CALENDAR/                  # Alternative calendar assets
│   │       ├── app.js
│   │       └── styles.css
│   │
│   └── templates/                     # Jinja2 HTML templates
│       ├── calendar.html              # Main calendar view
│       ├── admin.html                 # Admin console
│       └── events.html                # Events listing page
│
├── calendar/                          # Additional calendar files
│   └── index.html
│
├── notes for the read.me/             # Notes and documentation
│
├── run.py                             # Application entry point
├── requirements.txt                   # Python dependencies
├── bettermysqldatabase.sql            # Main database schema SQL script
│
├── eer diagram.png                    # Entity Relationship Diagram image
│
└── README.md                          # This file
```

### File Descriptions

#### Backend Files

- **`backend/app.py`**: 
  - Creates Flask app instance using application factory pattern
  - Initializes extensions (SQLAlchemy, Flask-Migrate)
  - Registers blueprints
  - Defines root route

- **`backend/config.py`**: 
  - Handles database connection string construction
  - Reads from environment variables
  - URL-encodes credentials to handle special characters

- **`backend/models.py`**: 
  - Defines all database models with SQLAlchemy
  - Includes relationships and serialization methods
  - Models: Sport, Competition, Team, CompetitionSeason, Venue, Event, Period

- **`backend/routes.py`**: 
  - Contains all API endpoints in a blueprint
  - Request validation and error handling
  - Score resolution logic (event scores vs. period aggregation)

- **`run.py`**: 
  - Entry point that creates app and runs development server
  - Configures host, port, and debug mode

#### Frontend Files

- **`backend/static/calendar/app.js`**: 
  - Frontend JavaScript for event fetching
  - Filtering and form handling
  - DOM manipulation and API interactions

- **`backend/static/calendar/styles.css`**: 
  - Modern CSS styling with responsive design
  - CSS Grid and Flexbox layouts
  - CSS variables for theming

- **`backend/templates/calendar.html`**: 
  - Main user-facing calendar interface template
  - Jinja2 template with Flask integration

- **`backend/templates/admin.html`**: 
  - Administrative interface for event management
  - Forms for creating/updating/deleting events

#### Database Files

- **`bettermysqldatabase.sql`**: 
  - Complete database schema with all tables
  - Foreign keys, constraints, and indexes
  - Use this for initial database setup

- **`populate_from_api.sql`**: 
  - Scripts to populate database from external API
  - Includes team and competition data

- **`populate_withmultiple_sports.sql`**: 
  - Scripts to add multiple sports and related data

#### Migration Scripts

- **`fix_scores_issue.sql`**: 
  - Adds `home_score` and `away_score` columns to event table
  - Populates scores from period aggregation

- **`update_event_scores_from_periods.sql`**: 
  - Updates event-level scores from period data

---

## 🌐 API Endpoints

### Base URL

```
http://localhost:5000/events
```

All endpoints return JSON responses.

### Endpoints

#### `GET /events`

Retrieve all events with full details including teams, competition, sport, and venue.

**Query Parameters**: None (future: filtering by sport, date, status)

**Response**: `200 OK`

```json
[
  {
    "event_id": 1,
    "competition_season_id": 1,
    "event_date": "2024-12-25",
    "start_time": "15:00",
    "status": "played",
    "home_score": 2,
    "away_score": 1,
    "score": "2 - 1",
    "home_team": {
      "team_id": 1,
      "name": "Team A",
      "official_name": "Team A Official",
      "slug": "team-a",
      "abbreviation": "TA",
      "country": "Country A"
    },
    "away_team": {
      "team_id": 2,
      "name": "Team B",
      "official_name": "Team B Official",
      "slug": "team-b",
      "abbreviation": "TB",
      "country": "Country B"
    },
    "venue": {
      "venue_id": 1,
      "name": "Stadium Name",
      "city": "City"
    },
    "competition": {
      "competition_id": 1,
      "name": "Premier League",
      "phase": "Regular Season",
      "season_id": 2024
    },
    "sport": {
      "sport_id": 1,
      "name": "Football"
    }
  }
]
```

**Score Resolution Logic**:
- If `home_score` and `away_score` exist on event, use those
- Otherwise, aggregate scores from `period` table
- If scores exist (from either source), status is automatically set to "played"

#### `GET /events/<event_id>`

Retrieve a specific event by ID.

**URL Parameters**:
- `event_id` (integer): The unique identifier of the event

**Response**: 
- `200 OK` - Event found and returned
- `404 Not Found` - Event does not exist

```json
{
  "event_id": 1,
  "competition_season_id": 1,
  "event_date": "2024-12-25",
  "start_time": "15:00",
  "status": "played",
  "home_score": 2,
  "away_score": 1,
  "score": "2 - 1",
  "home_team": { ... },
  "away_team": { ... },
  "venue": { ... },
  "competition": { ... },
  "sport": { ... }
}
```

#### `POST /events`

Create a new event.

**Request Body**:
```json
{
  "competition_season_id": 1,    // Required (integer)
  "event_date": "2024-12-25",    // Required (ISO format: YYYY-MM-DD)
  "start_time": "15:00",         // Optional (ISO format: HH:MM or HH:MM:SS)
  "home_team_id": 1,             // Required (integer)
  "away_team_id": 2,             // Required (integer, must differ from home_team_id)
  "venue_id": 1,                 // Optional (integer)
  "status": "scheduled",         // Optional (string, default: "scheduled")
  "home_score": null,            // Optional (integer)
  "away_score": null             // Optional (integer)
}
```

**Validation Rules**:
- `home_team_id` and `away_team_id` must be different
- `event_date` must be in ISO format (YYYY-MM-DD)
- `start_time` must be in ISO format (HH:MM or HH:MM:SS)
- All required fields must be present
- Foreign key references must exist (competition_season_id, team IDs, venue_id)

**Response**: 
- `201 Created` - Event successfully created
- `400 Bad Request` - Validation error or missing required fields

```json
{
  "event_id": 1,
  "competition_season_id": 1,
  "event_date": "2024-12-25",
  ...
}
```

#### `PATCH /events/<event_id>`

Update mutable fields on an event.

**URL Parameters**:
- `event_id` (integer): The unique identifier of the event

**Request Body** (all fields optional):
```json
{
  "event_date": "2024-12-26",    // ISO format: YYYY-MM-DD
  "start_time": "16:00",         // ISO format: HH:MM or HH:MM:SS
  "venue_id": 2,                 // integer or null
  "status": "played",            // string
  "home_score": 3,               // integer or null
  "away_score": 2                // integer or null
}
```

**Response**: 
- `200 OK` - Event successfully updated
- `404 Not Found` - Event does not exist
- `400 Bad Request` - Validation error

Returns the updated event object.

#### `DELETE /events/<event_id>`

Delete an event by ID.

**URL Parameters**:
- `event_id` (integer): The unique identifier of the event

**Response**: 
- `200 OK` - Event successfully deleted
- `404 Not Found` - Event does not exist

```json
{
  "message": "Event deleted"
}
```

**Note**: This operation is irreversible. Related period records will be deleted due to cascade delete.

### Error Responses

All error responses follow this format:

```json
{
  "error": "Error message description",
  "details": "Additional error details (if available)"
}
```

Common HTTP status codes:
- `400 Bad Request`: Invalid input data, validation failure, or constraint violation
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server-side error (check server logs)

### Example Error Responses

**Missing Required Field**:
```json
{
  "error": "Missing required fields: competition_season_id, event_date"
}
```

**Validation Error**:
```json
{
  "error": "home_team_id and away_team_id must differ"
}
```

**Not Found**:
```json
{
  "error": "Event not found"
}
```

**Database Constraint Violation**:
```json
{
  "error": "Failed to create event",
  "details": "Foreign key constraint violation"
}
```

---


## EER Diagram

The Entity-Relationship (EER) diagram for this project is available as:<img width="1611" height="1241" alt="eer diagram" src=¨https://github.com/slaymyfear/backend-sport-event-calendar/blob/main/eer%20diagram.png¨ />

**File**: `eer diagram.png`

This diagram visually represents:
- All database tables and their relationships
- Primary keys (PK) and foreign keys (FK)
- Cardinality (one-to-many, many-to-many relationships)
- Entity attributes and data types

### Key Relationships Shown in EER Diagram

1. **Sport → Competition**: One-to-Many (one sport has many competitions)
2. **Competition → CompetitionSeason**: One-to-Many (one competition has many seasons)
3. **CompetitionSeason → Event**: One-to-Many (one season has many events)
4. **Team → Event**: Many-to-Many (teams participate in events as home or away)
5. **Venue → Event**: One-to-Many (one venue hosts many events)
6. **Event → Period**: One-to-Many (one event has many periods)
7. **Player → Lineup**: Many-to-Many (players in lineups)
8. **Team → Coach**: One-to-Many (one team can have many coaches)

### Viewing the EER Diagram

- **Image File**: Open `eer diagram.png` in any image viewer
- **MySQL Workbench**: Open `diagram.mwb` in MySQL Workbench for interactive viewing and editing

---


## EER DIAGRAM
<img width="1611" height="1241" alt="eer diagram" src="https://github.com/user-attachments/assets/d93978a4-31b5-42f1-8106-e6aaa9d64060" />

---
