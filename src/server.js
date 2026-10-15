const fs = require("fs");
const path = require("path");
const express = require("express");
const { add } = require("./calculator");
const app = express();
const port = process.env.PORT || 3000;
const environmentName = process.env.APP_ENVIRONMENT || "local";

function readBuildInfo() {
  try {
    return fs
      .readFileSync(path.join(__dirname, "..", "build-info.txt"), "utf8")
      .trim();
  } catch (err) {
    return "local-build";
  }
}

const buildInfo = readBuildInfo();
app.get("/health", (req, res) => {
  res.json({ status: "ok" });
});

app.get("/api/add", (req, res) => {
  const a = Number(req.query.a);
  const b = Number(req.query.b);
  if (Number.isNaN(a) || Number.isNaN(b)) {
    return res
      .status(400)
      .json({ error: "Provide numeric query values a and b" });
  }
  res.json({ a, b, result: add(a, b) });
});
app.get("/", (req, res) => {
  res.send(`<h1>Calculator App</h1><p>Environment: ${environmentName}</p>
<p>Build: ${buildInfo}</p>`);
});
app.listen(port, () => {
  console.log(`Server listening on port ${port}`);
});
