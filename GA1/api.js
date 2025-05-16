// API functions to interact with the Python backend

// Base URL for API requests
const API_URL = 'http://localhost:8000';

// Load high scores from the server
export async function loadHighScores() {
  try {
    const response = await fetch(`${API_URL}/scores`);
    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`);
    }
    return await response.json();
  } catch (error) {
    console.error('Error loading high scores:', error);
    // Return empty array if server is not available
    return [];
  }
}

// Submit a new score to the server
export async function submitScore(name, score) {
  try {
    const response = await fetch(`${API_URL}/scores`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ name, score }),
    });
    
    if (!response.ok) {
      throw new Error(`HTTP error! Status: ${response.status}`);
    }
    
    return await response.json();
  } catch (error) {
    console.error('Error submitting score:', error);
    throw error;
  }
}