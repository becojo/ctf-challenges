from typing import AsyncIterable
from google.adk.agents.llm_agent import LlmAgent
from google.adk.events.event import Event
from google.adk.apps.app import App

from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai import types

from model import ParrotLm
from plugins import AuthPlugin, SanitizePlugin, StateFormatPlugin


async def get_events(prompt: str, state: dict = {}) -> AsyncIterable[Event]:
    app = App(
        name="big_parrot",
        root_agent=LlmAgent(
            name="RootAgent",
            model=ParrotLm(),
        ),
        plugins=[
            AuthPlugin(),
            StateFormatPlugin(),
            SanitizePlugin(
                redact_images=True,
                redact_links=True,
            ),
        ],
    )
    session_service = InMemorySessionService()
    session = await session_service.create_session(
        app_name=app.name,
        user_id="user",
        state=state,
    )
    runner = Runner(
        app=app,
        session_service=session_service,
    )

    message = types.UserContent(prompt)

    return runner.run_async(
        user_id=session.user_id,
        session_id=session.id,
        new_message=message,
    )


async def agent_response(prompt: str, state: dict = {}) -> str:
    output = ""
    async for event in await get_events(prompt, state=state):
        if (
            not event.content
            or not event.content.parts
            or not event.content.parts[0].text
        ):
            continue

        if event.content.parts[0].thought:
            continue

        output += event.content.parts[0].text

    return output
