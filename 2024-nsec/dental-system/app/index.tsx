import { Elysia, t } from "elysia";
import { html } from "@elysiajs/html";
import { createClient } from "redis";
import { config } from "./config.ts";
import { Traefik } from "./traefik.ts";
import mouth from "./mouth.json";
import { cron } from "@elysiajs/cron";
import teethSvg from "./assets/teeth.svg.txt";
import sketch from "./assets/sketch.js";
import { execSync } from "node:child_process";

const client = createClient({
  url: config.redisUrl,
});

await client.connect();

const authApp = new Elysia()
  .onError(({ error }) => error.toString())
  .post(
    "/auth/login",
    async ({ set, body: { username, password }, cookie: { authToken } }) => {
      const { result } = await fetch(config.opaLoginUrl, {
        method: "POST",
        body: JSON.stringify({
          input: { username, password },
        }),
      }).then((r) => r.json());

      if (result) {
        authToken.set({
          value: result,
          httpOnly: true,
          path: "/app",
        });
        set.redirect = "/app/";
        return;
      }

      set.redirect = "/?error=invalid+log+in+credentials";
    },
    { body: t.Object({ username: t.String(), password: t.String() }) },
  )
  .get(
    "/auth",
    async ({ set, cookie: { authToken }, request: { headers } }) => {
      const uri = headers.get("X-Forwarded-Uri");
      const { result } = await fetch(config.opaAuthUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          input: {
            authToken: authToken.value,
            uri,
          },
        }),
      }).then((r) => r.json());

      const { allowed, deny, user } = result;

      if (allowed) {
        set.status = 201;
        set.headers["X-Auth-User"] = user.sub;
      } else {
        set.status = 401;
        return { allowed, deny };
      }
    },
  )
  .listen({ hostname: "127.0.0.1", port: 1010 });

console.log(
  `Auth is running at http://${authApp.server?.hostname}:${authApp.server?.port}`,
);

function groupBy(array: any[], n: number = 2) {
  var groups = [];
  for (var i = 0; i < array.length; i += n) {
    groups.push(array.slice(i, i + n));
  }
  return groups;
}

function layout(args: any, body: any) {
  const styles = `
    body {
      margin: 0;
      background-image: linear-gradient(
        to right top,
        #3d444d,
        #3b444f,
        #384550,
        #354552,
        #324653
      );
      background-attachment: fixed;
      color: white;
    }

    #header {
      background-color: lightblue;
      color: blue;
      font-family: monospace;
      text-align: center;
      letter-spacing: 1em;
      font-weight: bold;
    }

    canvas {
    display: block;
    margin: 5% auto;
    border-radius: 100%;
    height: 600px !important;
  }

  canvas:after {
    content: "Root Manager";
    display: block;
    text-align: center;
    color: white;
    font-size: 2em;
    margin-top: 20px;
  }
  .left {
    float: left;
    width: 50%;
  }

  .modal {
    background-color: beige;
    padding: 50px 0px;
    position: absolute;
    border-radius: 100%;
    border: 2px solid rgba(0,0,0,0.5);
    width: 500px;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -70%);
    text-align: center;
    box-shadow: 10px 10px 10px rgba(0,0,0,0.5);
    color: black;
  }

  .box {
    border: 1px solid rgba(255,255,255,0.2);
    box-shadow: 2px 2px 3px rgba(0,0,0,0.2) inset;
    background-color: rgba(0,0,0,0.1);
    padding: 1em;
    max-width: 800px;
    margin: 2em auto;
  }
  `;

  return (
    <html class="no-js" lang="">
      <head>
        <meta charset="utf-8" />
        <meta http-equiv="x-ua-compatible" content="ie=edge" />
        <title>ROOT MANAGER</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <style>{styles}</style>
        <script
          src="https://cdn.jsdelivr.net/npm/p5@1.9.1/lib/p5.js"
          integrity="sha256-iAuyeVyvLm0+PZ+09c+48fruz9Fa4nFIJO2UBzikCBs="
          crossorigin="anonymous"
        ></script>
      </head>
      <body>
        <div id="header">ROOT MANAGER {args.title || ""}</div>

        {body}
      </body>
    </html>
  );
}

function mouthView() {
  return (
    <>
      <script>
        {sketch.toString()}
        var s = new p5({sketch.name});
      </script>

      <div>
        <div class="left">
          <canvas id="visualization"></canvas>
        </div>

        <div class="left">
          <h3 id="number"></h3>
          <p id="name">Please select a tooth.</p>
          <p id="defects"></p>

          <form action="/app/edit">
            <input id="q" name="q" type="hidden" value="" />
            <input type="submit" value="Edit properties" />
          </form>
        </div>
        <div class="clear"></div>
      </div>
    </>
  );
}

const app = new Elysia()
  .onError(() => "server error")
  .use(html())
  .get("/", () => {
    return layout(
      { title: "LOG IN" },
      <form action="/auth/login" method="POST" class="modal">
        <p>
          Username: <input name="username" type="text" value="" />
        </p>
        <p>
          Password: <input name="password" type="password" value="" />
        </p>
        <input type="submit" value="LOG IN" />
      </form>,
    );
  })

  .derive(({ request: { headers } }) => {
    return {
      currentUser: headers.get("X-Auth-User"),
    };
  })
  .get("/app/root-admin", async ({ currentUser }) => {
    if (currentUser !== "admin") {
      return `User '${currentUser}' does not have access to the root admin area.`;
    }

    return layout(
      { title: "ADMIN" },
      <div>
        <h1>ROOT MANAGER ADMIN</h1>
        <p>User: {currentUser}</p>
        <p>MOTD: {process.env.FLAG}</p>
        <p>Redis PING: {await client.ping()}</p>
        <p>Traefik dashboard: enabled</p>
      </div>,
    );
  })
  .get(
    "/app/get",
    async ({ query }) => {
      const { key } = query;
      return await client.get(key);
    },
    { query: t.Object({ key: t.String() }) },
  )
  .post(
    "/app/set",
    async ({ body, set }) => {
      const { key, value } = body;

      // avoid self-DoS
      if (key != "mouths/0/teeth" && key != "flag") {
        try {
          await client.set(key, value);
        } catch (e) {
          return `Error: ${e}`;
        }
      }

      set.redirect = "/app";
    },
    {
      body: t.Object({
        key: t.String({ maxLength: 256 }),
        value: t.String({ maxLength: 256 }),
      }),
    },
  )
  .get("/app/teeth.svg", () => {
    return new Response(teethSvg, {
      headers: {
        "Content-Type": "image/svg+xml",
      },
    });
  })
  .get(
    "/app",
    async () => {
      const teeth = await client.sMembers("mouths/0/teeth");
      const keys = teeth.flatMap((tooth) => [
        `mouths/0/teeth/${tooth}/type`,
        `mouths/0/teeth/${tooth}/defects`,
      ]);

      const values = await client.mGet(keys);
      const results = Object.fromEntries(
        keys
          .flatMap((key, i) => (values[i] && [[key, values[i]]]) || [])
          .concat([
            ["teeth", teeth as any],
            ["mouth", "0"],
          ]),
      );

      return layout(
        { title: "TEETH" },
        <div id="mouth" data-mouth={JSON.stringify(results)}>
          {mouthView()}
        </div>,
      );
    },
    { query: t.Object({ q: t.Optional(t.String()) }) },
  )
  .get("/app/edit", async ({ query }) => {
    let { q } = query;
    const search = [];

    if (q) {
      for await (const key of client.scanIterator({
        MATCH: `*${q}*`,
        COUNT: 20,
      })) {
        search.push(key);
      }
    }

    function scripts() {
      window.teeth = {
        read: (key: string) => {
          fetch(`/app/get?key=${key}`)
            .then((r) => r.text())
            .then(alert);
        },

        write: (key: string) => {
          var value = prompt("Enter value");
          if (!value) return;
          fetch("/app/set", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: `key=${key}&value=${value}`,
          });
        },
      };
    }

    return layout(
      { title: "EDIT" },
      <div class="box">
        <form
          action="?"
          onsubmit="this.q.value = `mouths/0/*${this.search.value}`"
        >
          <input type="text" name="search" placeholder="*" />
          <input name="q" type="hidden" value={q + ""} />
          <input type="submit" value="Search" />
        </form>

        <h3>Properties</h3>
        <script>({scripts.toString()})()</script>

        <ul>
          {search.map((key) => (
            <li>
              <code>{key}</code>

              <button onclick={`teeth.read(${JSON.stringify(key)})`}>
                read
              </button>
              <button onclick={`teeth.write(${JSON.stringify(key)})`}>
                edit
              </button>
            </li>
          ))}
        </ul>
      </div>,
    );
  })
  .get("/app/_debug/reset", () => {
    reset();
    return "ok";
  })
  .use(
    cron({
      name: "heartbeat",
      pattern: "*/1 * * * *",
      async run() {
        const response = await fetch(`http://127.0.0.1/app/root-admin`, {
          headers: {
            Cookie: process.env.ADMIN_JWT || "",
          },
        });

        if (!response.ok) {
          console.error("heartbeat error");
        }
      },
    }),
  )
  .listen({ port: 3000, hostname: "127.0.0.1" });

console.log(
  `Elysia is running at http://${app.server?.hostname}:${app.server?.port}`,
);

const resetApp = new Elysia()
  .use(html())
  .get("/", () => {
    return (
      <form action="/reset" method="POST">
        <input type="submit" value="FACTORY RESET ROOT MANAGER" />
      </form>
    );
  })
  .post("/reset", () => {
    execSync("systemctl restart app");
    return "ok";
  })
  .listen({ port: 4242, hostname: "[::]" });

async function reset() {
  await client.flushAll();

  await Traefik.build()
    .service("opa-svc", config.opaUrl)
    .service("app-svc", `http://${app.server?.hostname}:${app.server?.port}`)
    .service(
      "auth-svc",
      `http://${authApp.server?.hostname}:${authApp.server?.port}`,
    )
    .forwardAuthMiddleware("auth", config.authUrl)
    .router("index-router", "app-svc", "Path(`/`) || Path(`/login`)")
    .router("auth-router", "auth-svc", "PathPrefix(`/auth`)")
    .router(
      "opa-router",
      "opa-svc",
      "PathPrefix(`/v1/data/app`) && ClientIP(`127.0.0.1`)",
    )
    .router("app-router", "app-svc", "PathPrefix(`/app`)", ["auth"])
    // .router(
    //   "traefik-dashboard",
    //   "api@internal",
    //   "PathPrefix(`/api`) || PathPrefix(`/dashboard`)",
    // )
    .apply(client);

  for (let tooth of mouth.teeth) {
    let defects = {
      1: "Cavity",
      17: "Cavity",
      32: "Cracked tooth",
      8: "Discoloration (coffee)",
      9: "Discoloration (coffee)",
    }[tooth.tooth_number];

    client.sAdd("mouths/0/teeth", [`${tooth.tooth_number}`]);
    client.set(`mouths/0/teeth/${tooth.tooth_number}/type`, tooth.tooth_type);
    if (defects) {
      client.set(`mouths/0/teeth/${tooth.tooth_number}/defects`, defects);
    }
  }

  client.sAdd("flag", [`${process.env.REDIS_FLAG}`]);
}

await reset();
