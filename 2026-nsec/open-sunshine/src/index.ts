import { createServer } from "./server";
import { createMcpServer as part1 } from "./mcp";
import { createMcpServer as part2 } from "./mcp2";
import { config } from "./config";

let mcp;

switch (config.version) {
  case "1.0.0":
    mcp = await part1();
    break;
  case "1.0.1":
    mcp = await part2();
    break;
  default:
    throw new Error(`Unsupported version: ${config.version}`);
}

const app = createServer({ mcp });

app
  .listen(config.port, config.listen, () => {
    console.log(
      `Server is running on port http://${config.listen}:${config.port}`,
    );
  })
  .on("error", (err) => {
    console.error("Failed to start HTTP server:", err);
  });
