from agent import agent_response
import sys
import asyncio

prompt = " ".join(sys.argv[1:]) if len(sys.argv) > 1 else "Hello, world!"
print("<user>\n", prompt)
print("")

output = asyncio.run(agent_response(prompt))
print("<assistant>\n", output)
