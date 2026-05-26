const express = require("express");
const { DefaultAzureCredential } = require("@azure/identity");
const { BlobServiceClient } = require("@azure/storage-blob");

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

  if (!storageAccountName || !containerName) {
    return res.status(500).json({
      status: "failed",
      message: "Storage settings are missing",
      storageAccountConfigured: Boolean(storageAccountName),
      containerConfigured: Boolean(containerName)
    });
  }

  try {
    const credential = new DefaultAzureCredential();

    const blobServiceClient = new BlobServiceClient(
      `https://${storageAccountName}.blob.core.windows.net`,
      credential
    );

    const containerClient = blobServiceClient.getContainerClient(containerName);

    const blobName = `cloudnest-health-check-${Date.now()}.txt`;
    const blockBlobClient = containerClient.getBlockBlobClient(blobName);

    const content = `CloudNest storage write/read test successful at ${new Date().toISOString()}`;

    await blockBlobClient.upload(content, Buffer.byteLength(content), {
      blobHTTPHeaders: {
        blobContentType: "text/plain"
      }
    });

    const downloadedResponse = await blockBlobClient.downloadToBuffer();
    const downloadedContent = downloadedResponse.toString();

    res.json({
      status: "success",
      message: "App successfully wrote and read a blob using Managed Identity",
      storageAccountName,
      containerName,
      blobName,
      contentMatches: downloadedContent === content
    });
  } catch (error) {
    res.status(500).json({
      status: "failed",
      message: "Managed Identity storage write/read failed",
      error: error.message
    });
  }
});

app.listen(port, () => {
  console.log(`CloudNest app listening on port ${port}`);
});
