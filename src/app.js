const express = require('express');
const app = express();

const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.send('<h1>CloudNest App is running</h1><p>Project restored successfully.</p>');
});

app.listen(port, () => {
  console.log(`CloudNest app listening on port ${port}`);
});
