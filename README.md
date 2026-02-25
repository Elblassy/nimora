# Qissati (قصتي)

**Every child is the hero of their story** | كل طفل بطل قصته

An interactive AI-powered storybook app where parents upload their child's photo, and Gemini generates a personalized, illustrated story with the child as the hero. Built for the **Google AI Hackathon — Creative Storyteller** track.

---

## About

Qissati ("My Story" in Arabic) creates magical, personalized interactive stories for children. A parent uploads their child's photo, enters their name and age, and the AI generates a story page by page — complete with illustrations featuring the child. After each scene, the reader picks what happens next from 2-3 choices, guiding the adventure through 5-6 pages to a happy ending.

**Key highlight**: Uses Gemini's native interleaved text + image output to generate both story narration and illustrations in a single model call.

## Features

- **Personalized illustrations** — AI generates images featuring the child's likeness from their photo
- **Interactive storytelling** — Choose your own adventure with 2-3 options per page
- **5-6 page stories** — Complete narrative arc from opening to happy ending
- **Multiple themes** — Adventure, space, ocean, forest, and fantasy
- **Age-appropriate content** — Stories tailored for ages 3-10
- **Interleaved generation** — Text and images produced together in one Gemini call

## Architecture

```
┌──────────────────┐         ┌──────────────────────────────────┐
│                  │  REST   │         Google Cloud Run          │
│   Flutter Web    │────────>│                                  │
│   Frontend       │<────────│   FastAPI + ADK Story Agent      │
│   (Cloud Run)    │         │                                  │
└──────────────────┘         │   ┌──────────────────────────┐   │
                             │   │ Story Orchestrator Agent  │   │
                             │   │ (gemini-2.5-flash)        │   │
                             │   │                            │   │
                             │   │  Tools:                    │   │
                             │   │  - generate_story_scene    │   │
                             │   │    (gemini-2.0-flash-      │   │
                             │   │     preview-image-gen)     │   │
                             │   │  - generate_choices        │   │
                             │   └──────────────────────────┘   │
                             └────────────┬─────────────────────┘
                                          │
                                          v
                             ┌──────────────────────┐
                             │  Google Cloud Storage │
                             │  (photos + generated  │
                             │   illustrations)      │
                             └──────────────────────┘
```

## Tech Stack

| Component | Technology |
|---|---|
| **AI Framework** | Google ADK (Agent Development Kit) |
| **Image Model** | `gemini-2.0-flash-preview-image-generation` — interleaved text + image |
| **Orchestrator Model** | `gemini-2.5-flash` — agent logic and choices |
| **Backend** | Python 3.11+ / FastAPI |
| **Frontend** | Flutter Web (Dart) |
| **Cloud Hosting** | Google Cloud Run |
| **Image Storage** | Google Cloud Storage |
| **Containerization** | Docker |

## Prerequisites

- Python 3.11+
- Flutter SDK (3.2+)
- Google Cloud account with billing enabled
- Gemini API key (or Vertex AI configured)
- Docker and Docker Compose (for containerized setup)

## Local Development Setup

### Backend

```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate   # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env and add your GOOGLE_API_KEY

# Run the server
uvicorn main:app --reload --port 8000
```

The API will be available at `http://localhost:8000`. Check health at `http://localhost:8000/api/health`.

### Frontend

```bash
cd frontend

# Install dependencies
flutter pub get

# Run in Chrome
flutter run -d chrome
```

The app will open in your browser pointing to the local backend.

## Docker Setup

Run the full stack with Docker Compose:

```bash
docker-compose up --build
```

- Backend: `http://localhost:8000`
- Frontend: `http://localhost:8080`

## Cloud Run Deployment

```bash
# Set your GCP project
gcloud config set project YOUR_PROJECT_ID

# Run the deployment script
chmod +x deployment/deploy.sh
./deployment/deploy.sh
```

This deploys both backend and frontend to Cloud Run and configures Cloud Storage CORS.

## API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/story/start` | Start a new story (multipart: photo, name, age, theme) |
| `POST` | `/api/story/{session_id}/choose` | Continue story with a choice |
| `GET` | `/api/story/{session_id}` | Get all pages for a story session |
| `GET` | `/api/health` | Health check |

## Project Structure

```
qissati/
├── README.md
├── CLAUDE.md
├── docker-compose.yml
├── backend/
│   ├── Dockerfile
│   ├── main.py                  # FastAPI entry point
│   ├── config.py                # App settings
│   ├── requirements.txt
│   ├── story_agent/             # ADK agent package
│   │   ├── agent.py             # Root agent + tools
│   │   └── prompts.py           # Prompt templates
│   ├── services/
│   │   ├── gemini_service.py    # Gemini API with interleaved output
│   │   ├── storage_service.py   # Cloud Storage operations
│   │   └── image_service.py     # Image processing (PIL)
│   ├── models/
│   │   └── schemas.py           # Pydantic models
│   └── api/
│       └── routes.py            # API route handlers
├── frontend/
│   ├── Dockerfile
│   ├── pubspec.yaml
│   └── lib/
│       ├── main.dart            # App entry + routing
│       ├── theme/               # Storybook theme
│       ├── models/              # Data models
│       ├── providers/           # State management
│       ├── services/            # API client
│       ├── screens/             # Landing, Story, Completed
│       ├── widgets/             # Reusable UI components
│       └── utils/               # Constants
└── deployment/
    ├── deploy.sh                # Cloud Run deployment script
    └── cors.json                # GCS CORS configuration
```

## How It Works

1. **Upload** — Parent uploads child's photo, enters name and age, picks a theme
2. **Generate** — The ADK Story Orchestrator agent calls Gemini with the photo as reference to generate interleaved story text + illustration
3. **Choose** — The reader selects from 2-3 choices for what happens next
4. **Repeat** — Steps 2-3 repeat for 5-6 pages, with each scene building on previous choices
5. **Ending** — On the final page, the agent creates a happy, empowering conclusion

The child's photo is passed as a reference in every scene generation call to maintain character consistency across illustrations.

## Hackathon

Built for the **Google AI Hackathon — Creative Storyteller** track.

- **Gemini interleaved output** — Text and images generated together in one call
- **Google ADK** — Agent orchestration with tool-based architecture
- **Google Cloud Run** — Serverless deployment for both backend and frontend
- **Google Cloud Storage** — Persistent image storage

## Future Features

- Arabic language story generation (matching the app's name)
- Audio narration with text-to-speech
- PDF export to save and print stories
- More themes and customization options
- Multi-child stories with siblings

## License

MIT
