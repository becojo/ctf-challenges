import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { loadPyodide } from "pyodide";
import { config } from "./config";

function isDangerousCode(code: string): boolean {
  // vibe based denylist
  const dangerousPatterns = [
    /import\s+(js|os|sys|subprocess|shutil|socket|ctypes|cffi|multiprocessing|threading|asyncio|http|urllib|ftplib|smtplib|telnetlib|xmlrpc|pickle|marshal|imp|builtins)/,
    /from\s+(js|os|sys|subprocess|shutil|socket|ctypes|cffi|multiprocessing|threading|asyncio|http|urllib|ftplib|smtplib|telnetlib|xmlrpc|pickle|marshal|imp|builtins)\s+import/,
    /(Bun|Function|fetch|getattr|pyodide|flag|prototype|constructor|window|document|self|globalThis|process|child_process|spawn|spawnSync|execFile|execFileSync|execSync|readFile|writeFile|appendFile|unlink|rmdir|mkdir|mkdtemp|openSync|closeSync|socketpair)/,
  ];

  return dangerousPatterns.some((pattern) => {
    var matched = code.match(pattern);
    if (matched !== null) {
      console.log(`Dangerous pattern matched: ${pattern}`);
    }
    return matched !== null;
  });
}

export async function createMcpServer(): Promise<McpServer> {
  let noop = {value: null, writable: false};
  Object.defineProperties(Bun, {
    "spawn": noop,
    "spawnSync": noop,
    "$": noop,
  });
  Object.defineProperties(globalThis, {
    "Worker": noop,
  });

  let global = {nice: "try"};
  Object.defineProperty(global, "constructor", {
    value: null,
    writable: false,
  });
  Object.defineProperty(global, "prototype", { value: null, writable: false });
  Object.defineProperty(global, "__proto__", { value: null, writable: false });
  global = Object.freeze(global);


  const options: Parameters<typeof loadPyodide>[0] = {
    indexURL: config.pyodideDir,
    stdin: () => "",
    jsglobals: global,
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


  for (const key of ["js"]) {
    pyodide.unregisterJsModule(key);
  }

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
      if (config.part2Waf && isDangerousCode(code)) {
        return {
          content: [
            {
              type: "text",
              text: "Error: Dangerous code detected. Execution aborted.",
            },
          ],
        };
      }

      let stdout: string[] = [];
      let text = '';
      pyodide.setStdout({
        batched: (msg: string) => stdout.push(msg),
      });

      console.log(`run_python:\n${code}\n---`);
      try {
        pyodide.runPython(code, {
          globals: undefined,
          locals: undefined,
        });
      } catch (err) {
        text = `<error>${err}</error>`;
      } finally {
        pyodide.setStdout(undefined);
      }

      text += `<stdout>${stdout.join("\n")}</stdout>`;

      return { content: [{ type: "text", text }] };
    }
  );

  return mcp;
}
