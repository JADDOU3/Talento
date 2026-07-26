# Talento

Talento is a full-stack platform built for the **Injaz Arab** competition program, combining a Spring Boot backend, a FastAPI-based AI service, and a Flutter mobile frontend to deliver interactive, game-based activities with AI-powered behavioral analysis. The project was recognized as **Product of the Year (Injaz Arab, July 2026)**.

## Overview

Talento gamifies child development through interactive, level-based activities spanning cognitive, emotional, creative, and bodily categories, tracks progress through a roadmap system, and generates holistic behavioral reports using an AI analysis pipeline. Physical activity kits use QR codes to bridge real-world materials with the digital platform, and parental controls are enforced through a PIN-gated child mode.

## Features

### Activities & Gameplay
Activities are organized into four developmental categories, each built as interactive, level-based experiences (primarily maze and mini-game formats using Forge2D/Flame) rather than static exercises:

- **Cognitive** — Activities targeting problem-solving, memory, and pattern recognition, with progress tracked through level completion and in-game milestones.
- **Emotional** — Activities designed around emotional awareness and regulation, structured as guided, level-based experiences.
- **Creative** — Open-ended, building/composition-style activities that let children construct or arrange content within a structured framework (e.g. PIN-gated stages, JSON-driven content).
- **Bodily** — Activities involving physical/sensory interaction, including audio-matching exercises that pair digital feedback with physical materials.

Each activity plugs into the shared roadmap and progress system, so regardless of category, completion is tracked the same way across the platform.

### QR Codes

QR codes are used as the bridge between physical materials and the digital platform:

- Each physical activity kit ships with a **unique, per-box QR code**.
- Scanning a kit's QR code triggers redemption against the backend (`POST /api/kits/redeem`), which validates the code against a `redemption_codes` table and unlocks the corresponding digital content/activity for that user.
- Individual physical components within a kit (e.g. cards used in audio-matching activities) can carry their **own distinct codes**, allowing the app to identify which specific piece was scanned and trigger the matching digital response.
- Redemption codes are single-use and tied to a specific box/component, preventing a code from being reused across accounts once redeemed.

### Roadmap & Progress
- Roadmap cards (`RoadmapCard`) each reference a specific level range (`levelFrom` / `levelTo`) of an activity, so a single roadmap can route across parts of one activity or across multiple activities.
- Completion state is computed server-side from `ActivityProgress` records rather than being written directly by the client, keeping progress tamper-resistant and consistent.
- Attempts are tracked per level via `LevelAttempt` (replacing an earlier `ChallengeAttempt` model), which also backs session-duration calculations with a timestamp-based fallback.

### AI Behavioral Analysis
- A dedicated **FastAPI** service handles AI workloads independently of the core backend, communicating with it over REST rather than sharing a database or process space.
- Holistic, child-level behavioral reports are generated automatically when a child reaches milestone levels, rather than after every single attempt — reducing noise and giving reports enough history to be meaningful.
- Report generation draws on a child's accumulated `LevelAttempt` and session history, retrieved through **ChromaDB** as a RAG store so the model can ground its analysis in that child's own prior activity rather than generic heuristics.
- **OpenAI** models power both the written behavioral analysis (turning raw activity/session data into a readable report) and audio transcription (via Whisper) for any recorded voice input tied to an activity.
- Voice recordings are capped at a 3-minute maximum duration, enforced server-side with `mutagen` before a file is accepted for transcription, avoiding oversized uploads reaching the transcription step at all.
- Because the AI service is decoupled from the backend, it can be scaled, redeployed, or have its model/provider swapped independently of the rest of the platform.

### Voice-Over System
- Voice-over audio is modeled as its own `VoiceOver` entity, linked via foreign keys to the relevant activity and level, rather than being embedded as a field on the activity itself — allowing a level to have zero, one, or multiple recordings without schema changes.
- Files are uploaded and served through **AWS S3**, using presigned URLs generated per request rather than storing raw, long-lived URLs in the database, with guards against blank/empty `s3Key` values to prevent server errors when a recording hasn't finished uploading.
- Recorded audio can flow into the AI service for transcription and behavioral analysis, connecting the voice-over feature directly to the reporting pipeline rather than existing as an isolated playback feature.

### Child Mode & Access Control
- PIN-based **Child Mode** restricts or enables access to specific app features for younger users, letting a single device be handed to a child without exposing parent-facing settings, reports, or account management.
- Toggling out of Child Mode requires the PIN, so a child can't independently exit the restricted view.
- Backend authentication and authorization are handled via **Spring Security** with JWT and role-based access control, layered underneath the client-side PIN gate rather than replacing it — the PIN controls UI access, while JWT/roles control what the underlying API will actually return.

### Community Feed
- A shared feed feature for community-style interaction within the app, giving users a space to view and engage with shared content separate from the individual activity/roadmap flow.

### Notifications & Contact
- Contact form functionality is wired through **Gmail SMTP** for outbound email delivery.
- More scalable alternatives (Google Workspace, SendGrid, Amazon SES) were evaluated for production hardening, since SMTP through a personal/shared Gmail account has lower sending limits and weaker deliverability guarantees than a dedicated transactional email provider.

## Tech Stack

| Layer | Technologies |
|---|---|
| **Backend** | Java, Spring Boot, Spring Security (JWT, role-based auth), Hibernate/JPA, MySQL |
| **AI Service** | Python, FastAPI, ChromaDB (RAG), OpenAI (analysis & Whisper transcription) |
| **Frontend** | Flutter, Dart, Cubit (state management), Forge2D, Flame (game engine) |
| **Infrastructure** | Docker, Docker Compose, AWS EC2, AWS S3, Nginx |

## Project Structure

```
Talento/
├── Backend/     # Spring Boot REST API (controllers, services, DTOs, repositories)
├── ai/          # FastAPI AI service (RAG pipeline, transcription, behavioral analysis)
├── Frontend/    # Flutter mobile application
└── Docker/      # Docker Compose configuration for deployment
```

## Architecture

- The **Backend** follows a layered architecture — controllers → services → DTOs → repositories (`Repo` suffix naming convention) — with a MySQL database via Hibernate/JPA, exposing REST APIs consumed by the Flutter frontend.
- The **AI service** runs as an independent FastAPI process, using ChromaDB for retrieval-augmented generation and OpenAI models for both text analysis and audio transcription.
- The **Frontend** is a Flutter application using **Cubit** for state management, communicating with both the Backend and AI service to render activities, roadmaps, and reports.
- The full stack is containerized with **Docker Compose** and deployed on **AWS EC2** behind an **Nginx** reverse proxy, with media assets stored in **AWS S3**.
- Pagination across list-returning endpoints is handled through a shared `PaginationUtil`.
- Global error handling and logging is centralized through a `GlobalExceptionHandler`, which also helped surface subtle issues like a missing `Content-Type` header on multipart voice-upload requests.

**Typical data flow for a behavioral report:** the Flutter client records activity/level attempts through the Backend as a child plays → the Backend persists `LevelAttempt`/`ActivityProgress` records and stores any voice-over audio in S3 → at a milestone level, the AI service is invoked, pulls the child's relevant history via ChromaDB, transcribes any linked audio with Whisper, and generates a report with OpenAI → the report is returned to the Backend/Frontend for display. The Backend and AI service stay decoupled through this flow — the AI service never writes directly to the primary MySQL database.

### Selected API Endpoints

| Endpoint | Description |
|---|---|
| `POST /api/kits/redeem` | Redeem a unique per-box or per-component kit code |
| `GET /api/cart` / `POST /api/cart` | View and modify the current user's cart |
| `POST /api/orders` | Place an order from the current cart |
| `POST /api/reviews` | Submit a review for a purchased item |
| `GET /api/favorites` / `POST /api/favorites` | View and manage a user's favorited items |
| `POST /api/voice-overs` | Upload a voice recording linked to an activity/level |

All list-returning endpoints accept pagination parameters handled uniformly through `PaginationUtil`, so clients don't need endpoint-specific pagination logic.

*(See the `Backend` directory for the full, authoritative set of controllers and routes.)*

### Data Model Highlights

- `VoiceOver` — audio entity linked to an activity and level via foreign keys, backed by S3 storage.
- `RoadmapCard` — maps a roadmap entry to a `levelFrom`/`levelTo` range within an activity.
- `ActivityProgress` — source of truth for completion state, computed server-side.
- `LevelAttempt` — per-level attempt tracking, used for both progress and session-duration calculations (with a timestamp-based fallback when explicit duration data is missing).
- `redemption_codes` — unique QR redemption codes tied to physical/digital kits.

### Backend Conventions

- Package structure follows `org.example.backend.<Layer>` (e.g. `org.example.backend.Dto`), with a consistent `Repo` suffix for repository interfaces.
- Endpoint-level authorization includes explicit ownership validation (e.g. ensuring a user can only access or modify their own child's progress/reports), addressed as part of a security review that also flagged field-injection anti-patterns in favor of constructor injection.
- S3-backed resources use presigned URLs generated on request rather than persisting long-lived public URLs, reducing the surface area for stale or leaked links.

## Testing

- **Backend** — Java unit tests alongside **Cucumber** for behavior-driven (BDD) feature testing of key flows.
- API behavior (cart, orders, reviews, favorites, kit redemption) is exercised against documented request/response contracts rather than tested ad hoc.

## Deployment Notes

The stack is deployed via **Docker Compose** on an **AWS EC2** instance behind **Nginx**. A few real issues encountered and resolved during that process:

- **ChromaDB port mismatches** between the AI service container and its vector store caused silent connection failures until container networking was aligned.
- **SSL certificate path mismatches** inside the Nginx container blocked HTTPS termination until volume mounts were corrected.
- **`env_file` path errors** in `docker-compose.yml` caused services to boot with missing configuration rather than failing loudly.
- A **Python type-union syntax** (`X | Y`) incompatibility with the container's Python version crashed the AI service on startup; resolved by aligning the base image/interpreter version.
- A production **500 error on the voice transcription endpoint** was traced to a multipart request missing an explicit `Content-Type: application/json` part — caught after improving structured logging in `GlobalExceptionHandler`.

## Environment Variables

The application expects configuration to be supplied via environment variables rather than committed config files. At minimum:

| Variable | Used by | Purpose |
|---|---|---|
| `DB_URL`, `DB_USERNAME`, `DB_PASSWORD` | Backend | MySQL connection |
| `JWT_SECRET` | Backend | Signing/verifying auth tokens |
| `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_S3_BUCKET` | Backend | S3 presigned URL generation for media (voice-overs, images) |
| `OPENAI_API_KEY` | AI service | Behavioral analysis generation and Whisper transcription |
| `CHROMA_HOST`, `CHROMA_PORT` | AI service | Connecting to the ChromaDB vector store |
| `SMTP_HOST`, `SMTP_USERNAME`, `SMTP_PASSWORD` | Backend | Outbound contact-form email via Gmail SMTP |

Exact variable names may differ slightly between `Backend`, `ai`, and `Docker` — check each service's configuration files for the definitive list before deploying.

## Getting Started

### Prerequisites

- Java 17+ and Maven
- Python 3.10+
- Flutter SDK
- Docker & Docker Compose
- MySQL instance
- AWS account (S3 bucket for media storage)

### Running Locally with Docker

```bash
git clone https://github.com/JADDOU3/Talento.git
cd Talento/Docker
docker compose up --build
```

### Running Components Individually

**Backend**
```bash
cd Backend
./mvnw spring-boot:run
```

**AI Service**
```bash
cd ai
pip install -r requirements.txt
uvicorn main:app --reload
```

**Frontend**
```bash
cd Frontend
flutter pub get
flutter run
```

> Configuration such as database credentials, AWS keys, and API keys should be provided via environment variables / `.env` files (not committed to the repository).

## Award

🏆 **Product of the Year** — Injaz Arab (July 2026)
