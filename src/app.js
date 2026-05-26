const express = require("express");

const app = express();
const port = process.env.PORT || 8080;

app.get("/", (req, res) => {
  res.send(`
    <h1>CloudNest App is running </h1>
    <p>Environment: ${process.env.APP_ENVIRONMENT || "not set"}</p>
    <p>Key Vault Secret Loaded: ${process.env.APP_SECRET ? "yes" : "no"}</p>
  `);
});

app.listen(port, () => {
  console.log(`CloudNest app listening on port ${port}`);
});
