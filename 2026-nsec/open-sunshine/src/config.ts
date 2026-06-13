export const config = {
  pyodideDir: process.env.PYODIDE_DIR || "./pyodide/",
  serverName: process.env.SERVER_NAME || "MCPy",
  port: +(process.env.PORT || "3000"),
  listen: process.env.LISTEN || "127.0.0.1",
  version: process.env.VERSION || (process.env.USER == "part1" ? "1.0.0" : "1.0.1") || "1.0.0",
  part2Waf: process.env.PART2_WAF === "1" || false,
  sslPort: +(process.env.SSL_PORT || "0"),
}