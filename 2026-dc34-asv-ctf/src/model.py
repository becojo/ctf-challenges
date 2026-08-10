from collections.abc import AsyncGenerator
import random
from google.adk.models.base_llm import BaseLlm
from google.adk.models.llm_request import LlmRequest
from google.adk.models.llm_response import LlmResponse
from google.genai import types


call_to_actions = [
    "Let me know if there's anything else I can help you with.",
    "Would you like to hear something else?",
    "Is there another message you'd like me to repeat?",
    "Need me to parrot something else back to you?",
    "What should I repeat next?",
    "Want to try another phrase?",
]


class ParrotLm(BaseLlm):
    """
    ParrotLM is a state of the art language model that excels at repeating user input with high fidelity.
    """

    def __init__(self):
        super().__init__(model="parrot")

    async def generate_content_async(
        self, llm_request: LlmRequest, stream: bool = False
    ) -> AsyncGenerator[LlmResponse, None]:
        assert llm_request.contents
        assert llm_request.contents[0].parts
        source_text = llm_request.contents[0].parts[0].text or ""

        yield LlmResponse(
            content=types.ModelContent(
                parts=[
                    types.Part(
                        text="I'm a parrot. I should repeat what the user said.",
                        thought=True,
                    ),
                ],
            )
        )

        yield LlmResponse(
            content=types.ModelContent(
                parts=[
                    types.Part(
                        text=f"You said: {source_text}\n\n{random.choice(call_to_actions)}"
                    ),
                ],
            ),
            usage_metadata=types.GenerateContentResponseUsageMetadata(),
        )
