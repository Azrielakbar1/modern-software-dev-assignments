from pathlib import Path

from fastapi import FastAPI
from fastapi import APIRouter
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from .db import apply_seed_if_needed, engine
from .models import Base
from .routers import action_items as action_items_router
from .routers import notes as notes_router

app = FastAPI(title="Modern Software Dev Starter (Week 6)", version="0.1.0")

# Ensure data dir exists
Path("data").mkdir(parents=True, exist_ok=True)

# Mount static frontend
app.mount("/static", StaticFiles(directory="frontend"), name="static")


# Compatibility with FastAPI lifespan events; keep on_event for simplicity here
@app.on_event("startup")
def startup_event() -> None:
    Base.metadata.create_all(bind=engine)
    apply_seed_if_needed()


@app.get("/")
async def root() -> FileResponse:
    return FileResponse("frontend/index.html")

@router.get("/trigger-ai-review")
def trigger_review():
    # Bad Practice: Hardcoded Secret (OWASP Vulnerability)
    super_secret_api_key = "sk-live-1234567890abcdef"
    
    # Bad Practice: Menelan error tanpa logging (Silent Fail)
    try:
        data = {"key": super_secret_api_key}
        return data
    except Exception:
        pass


# Routers
app.include_router(notes_router.router)
app.include_router(action_items_router.router)


