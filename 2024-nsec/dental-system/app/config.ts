export const defaults = {};
export const appEnv = (
  process.env.container == "lxc" ? "prod" : "dev"
) as keyof typeof environments;

export const environments = {
  prod: {
    redisUrl: "redis://127.0.0.1:6379",
    opaUrl: "http://127.0.0.1:8181",
    opaLoginUrl: "http://127.0.0.1/v1/data/app/authn/login",
    opaAuthUrl: "http://127.0.0.1/v1/data/app/authz",
    authUrl: "http://127.0.0.1/auth",
  },

  dev: {
    redisUrl: "redis://redis:6379",
    opaUrl: "http://opa:8181",
    opaLoginUrl: "http://opa:8181/v1/data/app/authn/login",
    opaAuthUrl: "http://opa:8181/v1/data/app/authz",
    authUrl: "http://auth:1010/auth",
  },
};

export const config = environments[appEnv];
