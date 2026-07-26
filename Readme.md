# 🌟 Talento

<div align="center">

![Talento](https://img.shields.io/badge/Talento-Child%20Development%20Platform-blueviolet?style=for-the-badge)

**An AI-Powered, Gamified Platform for Cognitive, Emotional, Creative & Bodily Child Development**

[![Java](https://img.shields.io/badge/Java-ED8B00?style=flat-square&logo=openjdk&logoColor=white)](https://www.java.com/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-6DB33F?style=flat-square&logo=springboot&logoColor=white)](https://spring.io/projects/spring-boot)
[![FastAPI](https://img.shields.io/badge/FastAPI-005571?style=flat-square&logo=fastapi)](https://fastapi.tiangolo.com/)
[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev/)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=flat-square&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white)](https://www.docker.com/)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=flat-square&logo=amazonaws&logoColor=white)](https://aws.amazon.com/)

🏆 **Product of the Year — Injaz Arab, July 2026**

[Features](#-features) • [Tech Stack](#-tech-stack) • [Getting Started](#-getting-started) • [Architecture](#-architecture) • [API Documentation](#-api-documentation) • [License](#-license)

</div>

---

## 📖 Overview

**Talento** is a full-stack platform that turns child development activities into interactive, level-based experiences, tracked through a shared roadmap system and analyzed by an AI behavioral reporting pipeline. It bridges physical activity kits and digital gameplay through QR codes, and gives parents and guardians oversight through a PIN-gated child mode.

### 🎯 Key Highlights

- 🧩 **Four Developmental Categories**: Cognitive, emotional, creative, and bodily activities, all tracked through one unified progress system
- 🗺️ **Roadmap-Driven Progress**: Level-range-based roadmap cards route children through activities in a structured sequence
- 🤖 **AI Behavioral Reports**: Milestone-triggered, holistic reports generated via a dedicated FastAPI + RAG pipeline
- 🎙️ **Voice-Over & Transcription**: Recorded audio flows straight into AI transcription and analysis
- 📦 **QR-Linked Physical Kits**: Real-world activity kits and components unlock digital content via unique QR codes
- 🔐 **PIN-Gated Child Mode**: Keeps parent-facing settings and reports separate from the child's experience
- 💬 **Community Feed**: A shared space for platform-wide interaction
- ☁️ **Cloud-Native Deployment**: Dockerized services running on AWS EC2 behind Nginx, with S3-backed media storage

---

## ✨ Features

### 🧠 Activities & Gameplay

Activities span four developmental categories, each delivered as interactive, level-based experiences:

| Category | Focus |
|---|---|
| 🧩 **Cognitive** | Problem-solving, memory, and pattern recognition, tracked through level completion and in-game milestones |
| ❤️ **Emotional** | Emotional awareness and regulation through guided, level-based experiences |
| 🎨 **Creative** | Open-ended building/composition activities within a structured framework |
| 🏃 **Bodily** | Physical/sensory interaction, including exercises that pair digital feedback with physical materials |

Every activity — regardless of category — plugs into the same roadmap and progress system, so completion is tracked consistently platform-wide.

### 📦 QR Codes

QR codes are the bridge between physical materials and the digital platform:

- Each physical activity kit ships with a **unique, per-box QR code**.
- Scanning a kit's code triggers redemption against the backend, validating it against a dedicated codes table and unlocking the matching digital content.
- Individual physical components within a kit can carry **their own distinct codes**, letting the app identify exactly which piece was scanned and trigger the right digital response.
- Codes are single-use and tied to a specific box/component, so they can't be redeemed twice across accounts.

### 🗺️ Roadmap & Progress Tracking

- Roadmap cards each reference a specific level range of an activity, so a single roadmap can route across parts of one activity or span several.
- Completion state is computed **server-side** from progress records rather than written directly by the client — keeping it tamper-resistant and consistent.
- Attempts are tracked per level, which also backs session-duration calculations with a timestamp-based fallback.

### 🤖 AI Behavioral Analysis

- A dedicated **FastAPI** service handles all AI workloads, decoupled from the core backend and communicating over REST.
- Holistic, child-level behavioral reports are generated automatically at milestone levels rather than after every attempt, keeping reports meaningful rather than noisy.
- Report generation is grounded in a child's own history via a **ChromaDB**-backed RAG pipeline, rather than relying on generic heuristics.
- **OpenAI** models generate the written analysis and transcribe any linked audio via **Whisper**.
- Voice recordings are capped at 3 minutes, enforced server-side before a file is even accepted for transcription.

### 🎙️ Voice-Over System

- Voice-over audio is modeled as its own entity linked to a specific activity and level, so a level can have zero, one, or multiple recordings.
- Files are stored in **AWS S3** and served via presigned URLs generated per request rather than persisted long-lived links.
- Recorded audio connects directly into the AI transcription and reporting pipeline rather than existing as an isolated playback feature.

### 🔐 Child Mode & Access Control

- PIN-based **Child Mode** restricts app access to a child-safe view, hiding parent-facing settings, reports, and account management.
- Exiting Child Mode requires the PIN, so a child can't independently step out of the restricted view.
- Underneath the PIN gate, **Spring Security** with JWT and role-based access control governs what the API will actually return — the PIN controls UI access, JWT/roles control data access.

### 💬 Community Feed

A shared feed for community-style interaction, separate from the individual activity/roadmap flow.

### 📧 Notifications & Contact

- Contact form functionality is wired through **Gmail SMTP** for outbound email.
- More scalable alternatives (Google Workspace, SendGrid, Amazon SES) were evaluated for production, since personal/shared SMTP has lower sending limits and weaker deliverability than a dedicated transactional email provider.

---

## 🛠 Tech Stack

### Backend
- **Language**: Java
- **Framework**: Spring Boot
- **Security**: Spring Security (JWT, role-based access control)
- **ORM**: Hibernate / JPA
- **Database**: MySQL
- **Testing**: JUnit, Cucumber (BDD)

### AI Service
- **Language**: Python
- **Framework**: FastAPI
- **Vector Store**: ChromaDB (RAG)
- **AI Provider**: OpenAI (analysis + Whisper transcription)
- **Audio Validation**: mutagen

### Frontend
- **Framework**: Flutter (Dart)
- **State Management**: Cubit
- **Game Engine**: Forge2D + Flame

### Infrastructure
- **Containerization**: Docker, Docker Compose
- **Hosting**: AWS EC2
- **Storage**: AWS S3 (presigned URLs)
- **Reverse Proxy**: Nginx

---

## 🚀 Getting Started

### Prerequisites

- Java 17+ and Maven
- Python 3.10+
- Flutter SDK
- Docker & Docker Compose
- MySQL instance
- AWS account with an S3 bucket

### Quick Start with Docker

```bash
git clone https://github.com/JADDOU3/Talento.git
cd Talento/Docker
docker compose up --build
```

Docker Compose brings up the backend, AI service, and MySQL database with networking configured between them.

```bash
# Stop all services
docker compose down
```

### Manual Setup (Without Docker)

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

> Configuration such as database credentials, AWS keys, and API keys must be provided via environment variables / `.env` files — never commit these to the repository.

---

## 📁 Project Structure

```
Talento/
├── Backend/     # Spring Boot REST API (controllers, services, DTOs, repositories)
├── ai/          # FastAPI AI service (RAG pipeline, transcription, behavioral analysis)
├── Frontend/    # Flutter mobile application
└── Docker/      # Docker Compose configuration for deployment
```

---

## 🏗 Architecture

- The **Backend** follows a layered architecture — controllers → services → DTOs → repositories (`Repo` suffix naming convention) — backed by MySQL via Hibernate/JPA, and exposes REST APIs consumed by the Flutter frontend.
- The **AI service** runs as an independent FastAPI process, using ChromaDB for RAG and OpenAI for both analysis and transcription.
- The **Frontend** uses **Cubit** for state management, communicating with both the Backend and AI service to render activities, roadmaps, and reports.
- The stack is containerized with **Docker Compose** and deployed on **AWS EC2** behind **Nginx**, with media stored in **AWS S3**.
- Pagination across list-returning endpoints is handled through a shared utility, so clients don't need endpoint-specific pagination logic.
- Global error handling and logging is centralized, which has previously helped surface subtle production issues (e.g. a missing `Content-Type` header on multipart voice-upload requests).

**Typical data flow for a behavioral report:**
Flutter client records activity/level attempts as a child plays → Backend persists progress records and stores any voice-over audio in S3 → at a milestone level, the AI service is invoked, pulls the child's relevant history via ChromaDB, transcribes any linked audio with Whisper, and generates a report with OpenAI → the report is returned to the Backend/Frontend for display. The AI service never writes directly to the primary MySQL database, keeping the two services decoupled.

### Backend Conventions

- Package structure follows a consistent `<Layer>` convention (e.g. a dedicated DTO package), with a `Repo` suffix for repository interfaces.
- Endpoint-level authorization includes explicit ownership validation (e.g. ensuring a user can only access or modify their own child's progress/reports) — addressed as part of a security review that also flagged field-injection anti-patterns in favor of constructor injection.
- S3-backed resources use presigned URLs generated on request rather than persisting long-lived public URLs.

---

## 🔌 API Documentation

### Kits & Redemption
```http
POST /api/kits/redeem          # Redeem a unique per-box or per-component kit code
```

### Marketplace
```http
GET    /api/cart               # View current user's cart
POST   /api/cart               # Modify current user's cart
POST   /api/orders             # Place an order from the current cart
POST   /api/reviews            # Submit a review for a purchased item
GET    /api/favorites          # View a user's favorited items
POST   /api/favorites          # Manage a user's favorited items
```

### Voice-Over
```http
POST   /api/voice-overs        # Upload a voice recording linked to an activity/level
```

*(See the `Backend` directory for the full, authoritative set of controllers and routes.)*

---

## 🔒 Security

- **JWT Authentication** with role-based access control via Spring Security
- **Ownership validation** on endpoints handling per-child data
- **Constructor injection** in place of field injection, addressed via internal security review
- **Presigned S3 URLs** instead of persisted public links, reducing exposure from stale or leaked URLs
- **PIN-gated Child Mode** to separate parent-facing controls from the child-facing experience

---

## 🧪 Testing

- **Backend** — Java unit tests alongside **Cucumber** for behavior-driven (BDD) testing of key flows
- API behavior (cart, orders, reviews, favorites, kit redemption) is exercised against documented request/response contracts

---

## 🚧 Deployment Notes

The stack is deployed via Docker Compose on AWS EC2 behind Nginx. Notable issues encountered and resolved along the way:

- **ChromaDB port mismatches** between the AI service container and its vector store, causing silent connection failures until networking was aligned
- **SSL certificate path mismatches** inside the Nginx container blocking HTTPS termination until volume mounts were corrected
- **`env_file` path errors** in `docker-compose.yml` causing services to boot with missing configuration rather than failing loudly
- A **Python type-union syntax** incompatibility with the container's Python version crashing the AI service on startup
- A production **500 error on the voice transcription endpoint**, traced to a multipart request missing an explicit `Content-Type` part

---

## 🔑 Environment Variables

| Variable | Used by | Purpose |
|---|---|---|
| `DB_URL`, `DB_USERNAME`, `DB_PASSWORD` | Backend | MySQL connection |
| `JWT_SECRET` | Backend | Signing/verifying auth tokens |
| `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_S3_BUCKET` | Backend | S3 presigned URL generation for media |
| `OPENAI_API_KEY` | AI service | Behavioral analysis and Whisper transcription |
| `CHROMA_HOST`, `CHROMA_PORT` | AI service | Connecting to the ChromaDB vector store |
| `SMTP_HOST`, `SMTP_USERNAME`, `SMTP_PASSWORD` | Backend | Outbound contact-form email |

Exact variable names may differ slightly between `Backend`, `ai`, and `Docker` — check each service's configuration files before deploying.

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](./LICENSE) file for details.

---

<div align="center">

🏆 **Product of the Year — Injaz Arab, July 2026**

</div>
