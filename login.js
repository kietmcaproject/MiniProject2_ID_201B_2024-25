document.getElementById("loginForm").addEventListener("submit", async function (e) {
  e.preventDefault();
  const username = document.getElementById("loginUsername").value.trim();
  const password = document.getElementById("loginPassword").value.trim();
  const msg = document.getElementById("loginMsg");

  const response = await fetch("/api/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username, password }),
  });

  const result = await response.json();

  if (result.success) {
    msg.style.color = "green";
    msg.textContent = "Login successful! Redirecting...";
    setTimeout(() => {
      window.location.href = "index.html"; // Redirect to homepage
    }, 1000);
  } else {
    msg.textContent = result.message || "Login failed.";
  }
});
