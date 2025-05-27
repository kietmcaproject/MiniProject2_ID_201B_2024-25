import { useState } from "react";
import { useNavigate } from "react-router-dom";
import Navbar2 from "./Navbar2";

const JoinPage = () => {
  const [name, setName] = useState("");
  const [roomCode, setRoomCode] = useState("");
  const navigate = useNavigate();

  const token = sessionStorage.getItem("Authtoken");
  const username = localStorage.getItem("Username");

  const joinuser = async () => {
    if (!token) {
      console.error("No authentication token found.");
      return;
    }
    if (!roomCode) {
      console.error("Room code is required.");
      return;
    }
    // Prevent host from joining their own room
    const host = sessionStorage.getItem('RoomHost');
    if (host && host === username) {
      alert("You cannot join your own room.");
      return;
    }
    try {
      const response = await fetch(
        `http://localhost:8788/api/room/join?roomCode=${roomCode}&playerUsername=${username}`,
        {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${token}`,
            "Content-Type": "application/json"
          },
          body: JSON.stringify({ roomCode, username })
        }
      );

      if (!response.ok) {
        throw new Error(`Error: ${response.status} ${response.statusText}`);
      }

      const data = await response.text();
      console.log("Join response:", data);

      // Navigate to shared waiting room after join
      navigate(`/waiting-room?roomCode=${roomCode}&username=${encodeURIComponent(username)}`);

    } catch (error) {
      console.error("Error joining room:", error);
    }
  };

  return (
    <div>
      <Navbar2 />
      <div className="flex items-center justify-center min-h-screen bg-gray-100">
        <div className="bg-white p-6 rounded-lg shadow-lg w-96">
          <h1 className="text-2xl font-bold text-center mb-4">Join the Room</h1>
          {/* Name input removed, use username from localStorage */}
          <input
            type="text"
            placeholder="Enter room code"
            className="w-full p-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 mt-2"
            value={roomCode}
            onChange={(e) => setRoomCode(e.target.value)}
          />
          <button
            onClick={joinuser}
            className="w-full mt-4 bg-blue-500 text-white py-2 rounded-md hover:bg-blue-600 transition"
          >
            Join
          </button>
        </div>
      </div>
    </div>
  );
};

export default JoinPage;
