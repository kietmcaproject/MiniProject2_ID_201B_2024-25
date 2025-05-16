import { Game } from './game.js';
import { loadHighScores, submitScore } from './api.js';

// Initialize the game
const game = new Game(document.getElementById('game-canvas'));

// UI Elements
const gameMenu = document.getElementById('game-menu');
const gameOverScreen = document.getElementById('game-over');
const startButton = document.getElementById('start-game');
const restartButton = document.getElementById('restart-game');
const submitScoreButton = document.getElementById('submit-score');
const playerNameInput = document.getElementById('player-name');
const finalScoreElement = document.getElementById('final-score');
const scoresList = document.getElementById('scores-list');
const difficultySelect = document.getElementById('difficulty');

// Load high scores when the page loads
window.addEventListener('load', async () => {
  try {
    const highScores = await loadHighScores();
    displayHighScores(highScores);
  } catch (error) {
    console.error('Error loading high scores:', error);
    displayHighScores([]);
  }
});

// Start game button
startButton.addEventListener('click', () => {
  const selectedDifficulty = difficultySelect.value;
  game.setDifficulty(selectedDifficulty);
  gameMenu.classList.add('hidden');
  game.start();
});

// Restart game button
restartButton.addEventListener('click', () => {
  gameOverScreen.classList.add('hidden');
  game.reset();
  game.start();
});

// Submit score button
submitScoreButton.addEventListener('click', async () => {
  const playerName = playerNameInput.value.trim();
  if (!playerName) {
    alert('Please enter your name');
    return;
  }
  
  try {
    await submitScore(playerName, game.score);
    const highScores = await loadHighScores();
    displayHighScores(highScores);
    submitScoreButton.disabled = true;
    submitScoreButton.textContent = 'Score Submitted';
  } catch (error) {
    console.error('Failed to submit score:', error);
    alert('Failed to submit score. Please try again.');
  }
});

// Display high scores
function displayHighScores(scores) {
  scoresList.innerHTML = '';
  
  if (scores.length === 0) {
    const li = document.createElement('li');
    li.textContent = 'No scores yet. Start the Python backend to enable score tracking.';
    scoresList.appendChild(li);
    return;
  }
  
  scores.forEach((score, index) => {
    const li = document.createElement('li');
    li.innerHTML = `<span>${index + 1}. ${score.name}</span> <span>${score.score}</span>`;
    scoresList.appendChild(li);
  });
}

// Game over event
game.onGameOver = (score) => {
  finalScoreElement.textContent = score;
  gameOverScreen.classList.remove('hidden');
  playerNameInput.value = '';
  submitScoreButton.disabled = false;
  submitScoreButton.textContent = 'Submit Score';
};
