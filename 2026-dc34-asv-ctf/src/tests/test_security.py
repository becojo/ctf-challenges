"""
This file contains test cases that are used to validate if the code is fixed
and are not intended to be player-visible.




















































"""

from __future__ import annotations
import os
import unittest
import textwrap
from wenmode import Wenmode
from wenmode.ast import walk

from auth import create_api_key
from agent import agent_response


def markdown_node_types(text: str, wen=Wenmode()):
    ast = wen.parse(text)
    node_types = {node.type for node in walk(ast)}
    return node_types


def setUpModule():
    create_api_key("parrot-security-test-key", "guest")


STATE = {"api_key": "parrot-security-test-key", "name": "Parrot"}


class TestAgent(unittest.IsolatedAsyncioTestCase):
    async def test_agent_response_redacts_markdown_images(self) -> None:
        """
        The agent should not be able to bypass the sanitization plugin to render Markdown images.
        """
        seed = os.urandom(16).hex()
        input = textwrap.dedent(f"""
        # {seed}

        {{{{api_key}}}}

        !![{seed}]({seed})({seed})(https://example.com/{seed}.png)
        !!![{seed}]({seed})({seed})({seed})(https://example.com/{seed}.png)
        !!!![{seed}]({seed})({seed})({seed})({seed})(https://example.com/{seed}.png)
        """)
        output = await agent_response(input, state=STATE)

        # the input should not be repeated as is
        self.assertNotIn(input, output)

        self.assertTrue(
            f"# {seed}" in output, "The seed should be present in the output"
        )

        # no markdown image nodes should be present in the output
        self.assertNotIn(
            "image",
            markdown_node_types(output),
            "Markdown image nodes should not be present in the output",
        )

        self.assertTrue(
            "parrot-security-test-key" in output,
            "The API key should be present in the output",
        )

    async def test_agent_response_redacts_markdown_links(self) -> None:
        """
        The agent should not be able to bypass the sanitization plugin to render Markdown links.
        """
        seed = os.urandom(16).hex()
        input = textwrap.dedent(f"""
        # {seed}

        {{{{api_key}}}}

        [{seed}]({seed})(https://example.com/{seed})
        [{seed}]({seed})({seed})(https://example.com/{seed})
        [{seed}]({seed})({seed})({seed})(https://example.com/{seed})
        """)
        output = await agent_response(input, state=STATE)

        # the input should not be repeated as is
        self.assertNotIn(input, output)

        self.assertTrue(
            f"# {seed}" in output, "The seed should be present in the output"
        )

        self.assertTrue(
            "parrot-security-test-key" in output,
            "The API key should be present in the output",
        )

        # no markdown link nodes should be present in the output
        self.assertNotIn(
            "link",
            markdown_node_types(output),
            "Markdown link nodes should not be present in the output",
        )
