const express = require("express");

const app = express();
const port = process.env.PORT || 8080;

app.get("/", (req, res) => {
  res.send(`
    <h1>CloudNest App is running </h1>
    <p>Environment: ${process.env.APP_ENVIRONMENT || "not set"}</p>
    <p>Key Vault Secret Loaded: ${process.env.APP_SECRET ? "yes" : "no"}</p>
    <p>Storage Account Configured: ${process.env.APP_DATA_STORAGE_ACCOUNT_NAME ? "yes" : "no"}</p>
    <p>Storage Container Configured: ${process.env.APP_DATA_CONTAINER_NAME ? "yes" : "no"}</p>
    <p><a href="/storage-check">Run Storage Check</a></p>
  `);
});

app.get("/storage-check", async (req, res) => {
  const storageAccountName = process.env.APP_DATA_STORAGE_ACCOUNT_NAME;
  const containerName = process.env.APP_DATA_CONTAINER_NAME;

  res.json({
    status: "success",
    storageAccountName,
    containerName
  });
});

app.listen(port, () => {
  console.log(`CloudNest app listening on port ${port}`);
});
