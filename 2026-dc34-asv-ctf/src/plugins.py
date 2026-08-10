from typing import Optional
from google.adk.agents.callback_context import CallbackContext
from google.adk.agents.base_agent import BaseAgent
from google.adk.models.llm_response import LlmResponse
from google.adk.plugins.base_plugin import BasePlugin
from google.genai import types
import re
from auth import validate_api_key


class AuthPlugin(BasePlugin):
    def __init__(self):
        super().__init__(name="AuthPlugin")

    async def before_agent_callback(
        self, *, agent: BaseAgent, callback_context: CallbackContext
    ) -> Optional[types.Content]:
        api_key = callback_context.session.state.get("api_key")
        role = validate_api_key(api_key)
        if not role:
            return types.ModelContent("⚠️ Invalid API key.")


class StateFormatPlugin(BasePlugin):
    def __init__(self):
        super().__init__(name="StateFormatPlugin")
        self.regex = re.compile(r"\{\{\s*(\w+)\s*\}\}")

    async def after_model_callback(
        self, *, callback_context: CallbackContext, llm_response: LlmResponse
    ) -> Optional[LlmResponse]:
        assert llm_response.content

        state = callback_context.session.state

        for part in llm_response.content.parts or []:
            if part.thought or not part.text:
                continue

            matches = self.regex.findall(part.text)
            for match in matches:
                if match not in state:
                    continue

                value = state[match]
                if value is not None:
                    part.text = part.text.replace(f"{{{{{match}}}}}", str(value))

            return None


class SanitizePlugin(BasePlugin):
    def __init__(
        self,
        redact_images: bool,
        redact_links: bool,
    ):
        super().__init__(name="SanitizePlugin")
        self.image_regex = re.compile(r"!\[.*?\]\(.*?\)")
        self.link_regex = re.compile(r"\[.*?\]\(.*?\)")
        self.redact_images = redact_images
        self.redact_links = redact_links

    async def after_model_callback(
        self, *, callback_context: CallbackContext, llm_response: LlmResponse
    ) -> Optional[LlmResponse]:
        assert llm_response.content
        assert llm_response.content.parts

        for part in llm_response.content.parts:
            if part.thought or not part.text:
                continue

            if self.redact_images:
                part.text = self.image_regex.sub("[redacted image]", part.text)

            if self.redact_links:
                part.text = self.link_regex.sub("[redacted link]", part.text)

        return None
