app.post("/api/login", (req, res) => {
  const { username, password } = req.body;
  const users = JSON.parse(fs.readFileSync("./data/users.json"));

  const user = users.find(u => u.username === username && u.password === password);
  if (user) {
    res.json({ success: true, user: { id: user.id, username: user.username, role: user.role } });
  } else {
    res.status(401).json({ success: false, message: "Invalid credentials" });
  }
});
app.post("/api/register", (req, res) => {
  const { username, password } = req.body;
  const users = JSON.parse(fs.readFileSync("./data/users.json"));

  if (users.some(u => u.username === username)) {
    return res.status(409).json({ success: false, message: "Username already exists" });
  }

  const newUser = {
    id: users.length + 1,
    username,
    password,
    role: "user"
  };

  users.push(newUser);
  fs.writeFileSync("./data/users.json", JSON.stringify(users, null, 2));

  res.json({ success: true, message: "User registered successfully" });
});
const express = require("express");
const fs = require("fs");
const path = require("path");
const cors = require("cors");

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());
app.use(express.static("public"));

const usersPath = path.join(__dirname, "data", "users.json");

// Login Endpoint
app.post("/api/login", (req, res) => {
  const { username, password } = req.body;
  const users = JSON.parse(fs.readFileSync(usersPath));

  const user = users.find(
    (u) => u.username === username && u.password === password
  );

  if (user) {
    res.json({ success: true, user: { id: user.id, username: user.username, role: user.role } });
  } else {
    res.status(401).json({ success: false, message: "Invalid username or password" });
  }
});

// Register Endpoint
app.post("/api/register", (req, res) => {
  const { username, password } = req.body;
  let users = JSON.parse(fs.readFileSync(usersPath));

  if (users.find((u) => u.username === username)) {
    return res.status(409).json({ success: false, message: "Username already exists" });
  }

  const newUser = {
    id: users.length + 1,
    username,
    password,
    role: "user"
  };

  users.push(newUser);
  fs.writeFileSync(usersPath, JSON.stringify(users, null, 2));

  res.json({ success: true, message: "User registered successfully" });
});

app.listen(PORT, () => {
  console.log(`Server is running at http://localhost:${PORT}`);
});
