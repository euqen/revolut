import express from "express";
import routes from "./routes.js";
import healthz from "./modules/healthz/index.js";

import migrate from "../migrate.js";

const app = express();

app.use(express.json());
app.use(routes);

app.listen(3000, () => {
  console.log("Server is running on port 3000");
});


process.on("SIGINT", async () => {
  await healthz.startGracefullShutdown();
  app.close();
  process.exit(0);
});

process.on("SIGTERM", async () => {
  await healthz.startGracefullShutdown();
  app.close();
  process.exit(0);
});