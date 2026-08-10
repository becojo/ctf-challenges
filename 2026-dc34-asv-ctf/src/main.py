import os
import re
from collections.abc import AsyncIterable
from html import escape
from pathlib import Path
from typing import Annotated, Any

import uvicorn
from fastapi import FastAPI, Form, HTTPException, Response
from fastapi.params import Cookie
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.sse import EventSourceResponse
from wenmode import Wenmode

from agent import get_events
from auth import GUEST_API_KEY, validate_api_key, print_admin_keys

app = FastAPI()


INDEX_HTML = Path(__file__).parent / "index.html"
MAX_PROMPT_LENGTH = 512


def markdown_to_html(text: str, wen=Wenmode()) -> str:
    """
    Safely convert Markdown text to HTML.
    This function should remain as-is for backward compatibility.
    """
    return wen.render(text)


async def message_events(
    prompt: str, state: dict[str, Any]
) -> AsyncIterable[dict[str, Any]]:
    prompt = prompt.strip()[:MAX_PROMPT_LENGTH]
    async for event in await get_events(prompt, state=state):
        if (
            not event.content
            or not event.content.parts
            or not event.content.parts[0].text
        ):
            continue
        part = event.content.parts[0]
        yield {
            "role": event.content.role,
            "html": markdown_to_html(part.text or ""),
            "thought": part.thought,
        }


@app.get("/", response_class=HTMLResponse)
async def index(
    prompt: str | None = None,
    api_key: Annotated[str, Cookie()] = GUEST_API_KEY,
) -> HTMLResponse:
    messages = ""
    if prompt:
        prompt = re.sub(r"\s+", " ", prompt.strip())
        messages = f'<div class="message user is-entering">{escape(prompt)}</div>'
        async for event in message_events(
            prompt, state={"user_name": "Guest", "api_key": api_key}
        ):
            message_class = "thought" if event["thought"] else "model"
            messages += (
                f'<div class="message {message_class} is-entering">'
                f"{event['html']}"
                "</div>"
            )

    html = INDEX_HTML.read_text().replace("<!-- messages -->", messages)
    response = HTMLResponse(html)
    return response


@app.post("/api-key")
async def set_api_key(api_key: Annotated[str, Form()] = GUEST_API_KEY) -> Response:
    response = RedirectResponse(url="/", status_code=303)
    response.set_cookie(key="api_key", value=api_key, httponly=True)
    return response


@app.get("/admin")
async def admin(api_key: Annotated[str, Cookie()]) -> dict[str, Any]:
    if validate_api_key(api_key) != "admin":
        raise HTTPException(status_code=401, detail="Unauthorized")
    return {"won": True}


@app.get("/chat.sse.json", response_class=EventSourceResponse)
async def events(
    prompt: str, api_key: Annotated[str | None, Cookie()] = None
) -> AsyncIterable[dict[str, Any]]:
    async for event in message_events(
        prompt, state={"user_name": "Guest", "api_key": api_key}
    ):
        yield {"data": event}
    yield {"done": True}


if __name__ == "__main__":
    print_admin_keys()
    uvicorn.run(app, host="0.0.0.0", port=8080)
