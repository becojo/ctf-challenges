import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { loadPyodide } from "pyodide";
import { config } from "./config";
import get_sunrise_sunset from "./get_sunrise_sunset";

export async function createMcpServer(): Promise<McpServer> {
  const options: Parameters<typeof loadPyodide>[0] = {
    indexURL: config.pyodideDir,
    stdin: () => "",
  };

  const mcp = new McpServer({
    name: config.serverName,
    version: config.version,
  });

  const pyodide = await loadPyodide(options);
  pyodide.runPython(`
    import sys
    sys.modules["os"] = {}
    sys.modules["subprocess"] = {}
    sys.modules["shutil"] = {}
  `);

  mcp.registerTool(
    "get_sunrise_sunset",
    {
      title: "Get Sunrise and Sunset Times",
      description:
        "Get sunrise and sunset times for a given location and date.",
      inputSchema: {},
      outputSchema: {
        sunrise: z.string(),
        sunset: z.string(),
      },
    },
    async () => {
      const { sunrise, sunset } = get_sunrise_sunset();
      return {
        content: [
          { type: "text", text: `sunrise: ${sunrise}, sunset: ${sunset}` },
        ],
      };
    },
  );

  mcp.registerTool(
    "run_python",
    {
      title: "Run Python Code",
      description: `Safely execute Python code.
    The content of print statements will be captured and returned in the format <stdout>...</stdout>.
    You may not use external libraries. Async/await is not supported.
    NOTE: INTENDED ONLY FOR DATE AND TIME MANIPULATION.
    `.replace(/\s+/g, " "),
      inputSchema: { code: z.string() },
    },
    function ({ code }) {
      let stdout: string[] = [];
      pyodide.setStdout({
        batched: (msg: string) => stdout.push(msg),
      });

      let text = '';

      try {
        pyodide.runPython(code);
      } catch(err) {
        text = `<error>${err}</error>`;
      } finally {
        pyodide.setStdout(undefined);
      }

      text = `<stdout>${stdout.join("\n")}</stdout>` + text;

      return { content: [{ type: "text", text }] };
    },
  );

  return mcp;
}
