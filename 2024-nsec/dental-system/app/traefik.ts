import { RedisClientType } from "redis";

export class Traefik {
  values: Record<string, string> = {};

  static build() {
    return new Traefik();
  }

  service(id: string, url: string) {
    this.values[`traefik/http/services/${id}/loadbalancer/servers/0/url`] = url;
    return this;
  }

  tcpService(id: string, address: string) {
    this.values[`traefik/tcp/services/${id}/loadbalancer/servers/0/address`] =
      address;
    return this;
  }

  forwardAuthMiddleware(
    id: string,
    address: string,
    headers = ["X-Auth-User"],
  ) {
    this.values[`traefik/http/middlewares/${id}/forwardauth/address`] = address;
    this.values[
      `traefik/http/middlewares/${id}/forwardauth/authResponseHeaders`
    ] = headers.join(", ");

    return this;
  }

  router(
    id: string,
    service: string,
    rule: string,
    middlewares: string[] = [],
  ) {
    this.values[`traefik/http/routers/${id}/rule`] = rule;
    this.values[`traefik/http/routers/${id}/service`] = service;
    this.values[`traefik/http/routers/${id}/entrypoints/0`] = "web";

    middlewares.forEach((middleware, index) => {
      this.values[`traefik/http/routers/${id}/middlewares/${index}`] =
        middleware;
    });

    return this;
  }

  async apply(client: any) {
    for (const [key, value] of Object.entries(this.values)) {
      console.log("set", key, "=", value);
      await client.set(key, value);
    }
  }
}
