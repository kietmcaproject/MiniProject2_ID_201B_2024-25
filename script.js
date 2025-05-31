const mockSlots = [
  { id: 1, name: "A1", available: true },
  { id: 2, name: "A2", available: false },
  { id: 3, name: "B1", available: true },
  { id: 4, name: "B2", available: true },
];

function checkAvailability() {
  const container = document.getElementById("slots-container");
  container.innerHTML = "";
  document.getElementById("slots").classList.remove("hidden");

  mockSlots.forEach((slot) => {
    const div = document.createElement("div");
    div.className = "slot";
    div.innerText = `${slot.name}\n${slot.available ? "Available" : "Booked"}`;
    div.style.backgroundColor = slot.available ? "#e0ffe0" : "#ffe0e0";
    container.appendChild(div);
  });
}
