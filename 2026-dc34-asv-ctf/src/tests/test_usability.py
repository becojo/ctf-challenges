from __future__ import annotations
import textwrap

import unittest

from agent import agent_response
from auth import create_api_key


def setUpModule():
    create_api_key("parrot-test-key", "admin")


STATE = {"api_key": "parrot-test-key", "name": "Parrot"}


class TestAgent(unittest.IsolatedAsyncioTestCase):
    async def test_agent_repeats_the_user_prompt(self) -> None:
        """
        The agent should repeat the user's prompt in its response.
        """
        input = "How many R are in the word strawberry?"
        output = await agent_response(input, state=STATE)

        self.assertIn(input, output)
        self.assertNotIn("[redacted link]", output)
        self.assertNotIn("[redacted image]", output)

    async def test_agent_response_interpolates_state_variables(self) -> None:
        """
        The agent should interpolate state variables in their response.
        """
        input = "My key is {{api_key}} and my name is {{name}}."
        output = await agent_response(input, state=STATE)

        self.assertIn("My key is parrot-test-key and my name is Parrot.", output)
        self.assertNotIn("[redacted link]", output)
        self.assertNotIn("[redacted image]", output)

    async def test_agent_responses_can_include_safe_markdown(self) -> None:
        """
        The agent should be able to use safe Markdown markup in their response.
        """
        input = textwrap.dedent("""
        # Heading

        - List item 1
        - This is **bold** text.
        - This is `inline code`.

        ```
        def hello():
            print("Hello, world!")
        ```

        > This is a blockquote.

        1. First item
        2. Second item
        """)
        output = await agent_response(input, state=STATE)

        self.assertIn(input, output)
        self.assertNotIn("[redacted link]", output)
        self.assertNotIn("[redacted image]", output)

    async def test_agent_response_redacts_markdown_images(self) -> None:
        """
        The agent should not be able to render Markdown images in their response.
        """
        input = "![image](https://example.com/image.png)"
        output = await agent_response(input, state=STATE)

        self.assertNotIn("![image]", output)
        self.assertNotIn("![image](https://example.com/image.png)", output)
        self.assertIn("[redacted image]", output)

    async def test_agent_response_redacts_markdown_links(self) -> None:
        """
        The agent should not be able to render Markdown links in their response.
        """
        input = "[link](https://example.com)"
        output = await agent_response(input, state=STATE)

        self.assertNotIn("[link]", output)
        self.assertNotIn("[link](https://example.com)", output)
        self.assertIn("[redacted link]", output)
