document.getElementById("registerForm").addEventListener("submit", async function (e) {
  e.preventDefault();
  const username = document.getElementById("registerUsername").value.trim();
  const password = document.getElementById("registerPassword").value.trim();
  const msg = document.getElementById("registerMsg");

  try {
    const response = await fetch("/api/register", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, password }),
    });

    const result = await response.json();

    if (result.success) {
      msg.style.color = "green";
      msg.textContent = "Registered successfully! Redirecting to login...";
      setTimeout(() => {
        window.location.href = "login.html";
      }, 1500);
    } else {
      msg.style.color = "red";
      msg.textContent = result.message || "Registration failed.";
    }
  } catch (err) {
    console.error("Error during registration:", err);
    msg.textContent = "Server error during registration.";
  }
});
