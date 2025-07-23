import express from "express";
import routes from "./routes.js";
import config from "./config/index.js";
import graceful from "./utils/graceful.js";

const app = express();

app.use(express.json());
app.use(routes);

const port = config.port;

app.listen(port, () => console.log(`Server is running on port ${port}`));

process.on("SIGINT", async () => {
  await graceful.startGracefullShutdown();
  app.close();
  process.exit(0);
});

process.on("SIGTERM", async () => {
  await graceful.startGracefullShutdown();
  app.close();
  process.exit(0);
});