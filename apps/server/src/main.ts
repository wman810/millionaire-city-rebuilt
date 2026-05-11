import { createServerApp } from "./serverApp.js";

const serverApp = createServerApp();

serverApp
  .start()
  .then(({ facebookShim }) => {
    console.log(`[mcity] HTTP server listening at http://127.0.0.1:${serverApp.config.httpPort}`);
    console.log(`[mcity] HTTPS server listening at https://127.0.0.1:${serverApp.config.httpsPort}`);
    console.log(`[mcity] Launcher available at https://127.0.0.1:${serverApp.config.httpsPort}/launcher`);
    if (facebookShim) {
      console.log(`[mcity] HTTPS Facebook shim listening at ${facebookShim.url}`);
    }
  })
  .catch((error) => {
    console.error("[mcity] Failed to start server:", error);
    process.exitCode = 1;
  });

const shutdown = async () => {
  await serverApp.stop();
  process.exit(0);
};

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
