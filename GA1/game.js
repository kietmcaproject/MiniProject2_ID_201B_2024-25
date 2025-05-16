// game.js - Complete Enhanced Version
import { Player } from './player.js';
import { Enemy } from './enemy.js';
import { Bullet } from './bullet.js';
import { Powerup } from './powerup.js';

export class Game {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.width = canvas.parentElement.clientWidth;
    this.height = canvas.parentElement.clientHeight;
    canvas.width = this.width;
    canvas.height = this.height;

    // Game state
    this.isRunning = false;
    this.score = 0;
    this.level = 1;
    
    // Enhanced background system
    this.background = {
      layers: [],
      parallaxSpeed: [0.2, 0.5, 0.8],
      nebulaColors: [
        'rgba(138, 43, 226, 0.3)',  // Purple
        'rgba(70, 130, 180, 0.3)',   // Steel Blue
        'rgba(255, 105, 180, 0.3)',  // Pink
        'rgba(100, 149, 237, 0.3)'   // Cornflower Blue
      ]
    };
    
    // Initialize background layers
    for (let i = 0; i < 3; i++) {
      this.background.layers.push({
        stars: this.generateStars(150, i * 0.5 + 0.5),
        nebulae: this.generateNebulae(4, this.background.nebulaColors, i * 100),
        planets: this.generatePlanets(2, i * 200)
      });
    }

    // Difficulty settings
    this.difficulty = "Medium";
    this.difficultySettings = {
      Easy: { enemySpeed: 1, enemySpawnRate: 2500, playerHealth: 150, ammoBonus: 20 },
      Medium: { enemySpeed: 2, enemySpawnRate: 2000, playerHealth: 100, ammoBonus: 15 },
      Hard: { enemySpeed: 3, enemySpawnRate: 1500, playerHealth: 75, ammoBonus: 10 },
    };

    this.enemySpawnRate = this.difficultySettings[this.difficulty].enemySpawnRate;
    this.lastEnemySpawn = 0;
    this.powerupSpawnRate = 10000;
    this.lastPowerupSpawn = 0;

    // Game objects
    this.player = new Player(this.width / 2, this.height - 100, this);
    this.enemies = [];
    this.bullets = [];
    this.powerups = [];
    this.particles = [];

    // UI elements
    this.scoreElement = document.getElementById('score-value');
    this.healthElement = document.getElementById('health-value');
    this.ammoElement = document.getElementById('ammo-value');

    // Input handling
    this.keys = {};
    window.addEventListener('keydown', (e) => this.keys[e.code] = true);
    window.addEventListener('keyup', (e) => this.keys[e.code] = false);

    // Effects
    this.explosions = [];
  }

  generateStars(count, brightness = 1) {
    const stars = [];
    for (let i = 0; i < count; i++) {
      const size = Math.random() * 3 + 1;
      stars.push({
        x: Math.random() * this.width,
        y: Math.random() * this.height,
        size: size,
        baseSize: size,
        speed: Math.random() * 0.2 + 0.1,
        brightness: brightness,
        twinkleSpeed: Math.random() * 0.01 + 0.005,
        color: `hsl(${Math.random() * 60 + 200}, 100%, ${Math.random() * 30 + 70}%)`
      });
    }
    return stars;
  }

  generateNebulae(count, colors, seed) {
    const nebulae = [];
    for (let i = 0; i < count; i++) {
      nebulae.push({
        x: Math.random() * this.width,
        y: Math.random() * this.height,
        width: Math.random() * 400 + 200,
        height: Math.random() * 400 + 200,
        color: colors[Math.floor(Math.random() * colors.length)],
        rotation: Math.random() * Math.PI * 2,
        rotationSpeed: (Math.random() - 0.5) * 0.001,
        driftX: (Math.random() - 0.5) * 0.1,
        driftY: (Math.random() - 0.5) * 0.1
      });
    }
    return nebulae;
  }

  generatePlanets(count, seed) {
    const planets = [];
    const planetColors = [
      '#FF6B6B', '#4ECDC4', '#45B7D1', '#FFBE0B',
      '#FB5607', '#8338EC', '#3A86FF', '#FF006E'
    ];
    
    for (let i = 0; i < count; i++) {
      planets.push({
        x: Math.random() * this.width,
        y: Math.random() * this.height,
        radius: Math.random() * 50 + 30,
        color: planetColors[Math.floor(Math.random() * planetColors.length)],
        ring: Math.random() > 0.7,
        ringColor: `hsl(${Math.random() * 360}, 70%, 60%)`,
        rotation: Math.random() * Math.PI * 2,
        rotationSpeed: (Math.random() - 0.5) * 0.002
      });
    }
    return planets;
  }

  lightenColor(color, percent) {
    const num = parseInt(color.replace('#', ''), 16);
    const amt = Math.round(2.55 * percent);
    const R = (num >> 16) + amt;
    const G = (num >> 8 & 0x00FF) + amt;
    const B = (num & 0x0000FF) + amt;
    return `#${(
      0x1000000 +
      (R < 255 ? (R < 1 ? 0 : R) : 255) * 0x10000 +
      (G < 255 ? (G < 1 ? 0 : G) : 255) * 0x100 +
      (B < 255 ? (B < 1 ? 0 : B) : 255)
    ).toString(16).slice(1)}`;
  }

  setDifficulty(level) {
    if (this.difficultySettings[level]) {
      this.difficulty = level;
      this.enemySpawnRate = this.difficultySettings[level].enemySpawnRate;
      this.player.health = this.difficultySettings[level].playerHealth;
    }
  }

  start() {
    if (!this.isRunning) {
      this.isRunning = true;
      this.lastFrameTime = performance.now();
      requestAnimationFrame(this.gameLoop.bind(this));
    }
  }

  reset() {
    this.isRunning = false;
    this.score = 0;
    this.level = 1;
    this.enemySpawnRate = 2000;
    this.player = new Player(this.width / 2, this.height - 100, this);
    this.enemies = [];
    this.bullets = [];
    this.powerups = [];
    this.explosions = [];
    this.particles = [];
    this.updateUI();
  }
  
  gameLoop(timestamp) {
    if (!this.isRunning) return;
    
    const deltaTime = timestamp - this.lastFrameTime;
    this.lastFrameTime = timestamp;
    
    // Clear canvas with subtle trail effect
    this.ctx.fillStyle = 'rgba(15, 12, 41, 0.2)';
    this.ctx.fillRect(0, 0, this.width, this.height);
    
    this.update(deltaTime, timestamp);
    this.draw();
    
    requestAnimationFrame(this.gameLoop.bind(this));
  }
  
  update(deltaTime, currentTime) {
    // Update player
    this.player.update(deltaTime, this.keys);
    
    // Spawn enemies
    if (currentTime - this.lastEnemySpawn > this.enemySpawnRate) {
      this.spawnEnemy();
      this.lastEnemySpawn = currentTime;
    }
    
    // Spawn powerups
    if (currentTime - this.lastPowerupSpawn > this.powerupSpawnRate) {
      this.spawnPowerup();
      this.lastPowerupSpawn = currentTime;
    }
    
    // Update enemies - FIXED: Properly handle enemy removal
    for (let i = this.enemies.length - 1; i >= 0; i--) {
      const enemy = this.enemies[i];
      enemy.update(deltaTime);
      
      if (enemy.y > this.height) {
        this.enemies.splice(i, 1);
        this.player.takeDamage(10);
        
        // Check for game over after damage
        if (this.player.health <= 0) {
          this.gameOver();
          return; // Exit update if game is over
        }
      }
    }
    
    for (let i = this.bullets.length - 1; i >= 0; i--) 
    {
      const bullet = this.bullets[i];
      bullet.update(deltaTime);
      
      // Check both lifetime and boundaries
      const isExpired = performance.now() - bullet.createdTime > bullet.lifetime;
      const isOutOfBounds = bullet.y < 0 || bullet.y > this.height || 
                           bullet.x < 0 || bullet.x > this.width;
      
      if (isExpired || isOutOfBounds) {
          this.bullets.splice(i, 1);
      }
    }
    
    // Update powerups - FIXED: Properly handle powerup removal
    for (let i = this.powerups.length - 1; i >= 0; i--) {
      const powerup = this.powerups[i];
      powerup.update(deltaTime);
      
      if (powerup.y > this.height) {
        this.powerups.splice(i, 1);
      }
    }
    
    // Update explosions
    this.updateExplosions(deltaTime);
    
    // Update particles
    this.updateParticles(deltaTime);
    
    this.checkCollisions();
    this.updateUI();
    
    // Moved game over check to after all updates
    if (this.player.health <= 0) {
      this.gameOver();
    }
    
    this.updateDifficulty();
}

  updateExplosions(deltaTime) {
    this.explosions.forEach((explosion, index) => {
      explosion.time -= deltaTime;
      
      // Add secondary explosion particles
      if (explosion.time > explosion.maxTime * 0.7 && Math.random() < 0.3) {
        this.addParticles(
          explosion.x, 
          explosion.y, 
          5, 
          explosion.color, 
          explosion.radius * 0.5
        );
      }
      
      if (explosion.time <= 0) {
        this.explosions.splice(index, 1);
      }
    });
  }

  updateParticles(deltaTime) {
    this.particles.forEach((particle, index) => {
      particle.x += particle.vx;
      particle.y += particle.vy;
      particle.life -= deltaTime;
      
      if (particle.life <= 0) {
        this.particles.splice(index, 1);
      }
    });
  }
  
  draw() {
    // Draw space background with parallax
    this.drawSpaceBackground();
    
    // Draw explosions
    this.drawExplosions();
    
    // Draw particles
    this.drawParticles();
    
    // Draw game objects
    this.player.draw(this.ctx);
    this.enemies.forEach(enemy => enemy.draw(this.ctx));
    this.bullets.forEach(bullet => bullet.draw(this.ctx));
    this.powerups.forEach(powerup => powerup.draw(this.ctx));
    
    // Draw UI elements
    this.drawUI();
  }
  
  drawSpaceBackground() {
    // Draw gradient background
    const gradient = this.ctx.createLinearGradient(0, 0, 0, this.height);
    gradient.addColorStop(0, '#0f0c29');
    gradient.addColorStop(0.5, '#302b63');
    gradient.addColorStop(1, '#24243e');
    this.ctx.fillStyle = gradient;
    this.ctx.fillRect(0, 0, this.width, this.height);

    // Draw each background layer with parallax
    this.background.layers.forEach((layer, layerIndex) => {
      const parallaxOffset = (performance.now() * this.background.parallaxSpeed[layerIndex] * 0.1) % this.width;
      
      // Draw nebulae
      layer.nebulae.forEach(nebula => {
        this.ctx.save();
        this.ctx.translate(nebula.x + parallaxOffset, nebula.y);
        this.ctx.rotate(nebula.rotation);
        this.ctx.globalAlpha = 0.3;
        
        const gradient = this.ctx.createRadialGradient(
          0, 0, 0,
          0, 0, nebula.width * 0.5
        );
        gradient.addColorStop(0, nebula.color);
        gradient.addColorStop(1, 'transparent');
        
        this.ctx.fillStyle = gradient;
        this.ctx.beginPath();
        this.ctx.ellipse(0, 0, nebula.width * 0.5, nebula.height * 0.5, 0, 0, Math.PI * 2);
        this.ctx.fill();
        
        this.ctx.restore();
        
        // Update nebula movement
        nebula.rotation += nebula.rotationSpeed;
        nebula.x += nebula.driftX;
        nebula.y += nebula.driftY;
        
        // Wrap around screen edges
        if (nebula.x > this.width + nebula.width) nebula.x = -nebula.width;
        if (nebula.x < -nebula.width) nebula.x = this.width + nebula.width;
        if (nebula.y > this.height + nebula.height) nebula.y = -nebula.height;
        if (nebula.y < -nebula.height) nebula.y = this.height + nebula.height;
      });

      // Draw planets
      layer.planets.forEach(planet => {
        this.ctx.save();
        this.ctx.translate(planet.x + parallaxOffset * 0.5, planet.y);
        this.ctx.rotate(planet.rotation);
        
        // Draw planet
        this.ctx.fillStyle = planet.color;
        this.ctx.beginPath();
        this.ctx.arc(0, 0, planet.radius, 0, Math.PI * 2);
        this.ctx.fill();
        
        // Draw planet details
        this.ctx.fillStyle = this.lightenColor(planet.color, 20);
        this.ctx.beginPath();
        this.ctx.arc(
          planet.radius * 0.3,
          -planet.radius * 0.2,
          planet.radius * 0.4,
          0,
          Math.PI * 2
        );
        this.ctx.fill();
        
        // Draw ring if applicable
        if (planet.ring) {
          this.ctx.strokeStyle = planet.ringColor;
          this.ctx.lineWidth = 3;
          this.ctx.beginPath();
          this.ctx.ellipse(0, 0, planet.radius * 1.5, planet.radius * 0.3, planet.rotation * 2, 0, Math.PI * 2);
          this.ctx.stroke();
        }
        
        this.ctx.restore();
        
        // Update planet rotation
        planet.rotation += planet.rotationSpeed;
      });

      // Draw stars
      layer.stars.forEach(star => {
        const twinkle = Math.abs(Math.sin(performance.now() * star.twinkleSpeed));
        const currentSize = star.baseSize * (0.8 + twinkle * 0.5);
        
        this.ctx.save();
        this.ctx.fillStyle = star.color;
        this.ctx.globalAlpha = star.brightness * (0.7 + twinkle * 0.3);
        this.ctx.beginPath();
        this.ctx.arc(
          (star.x + parallaxOffset) % this.width,
          star.y,
          currentSize,
          0,
          Math.PI * 2
        );
        this.ctx.fill();
        this.ctx.restore();
      });
    });
  }

  drawExplosions() {
    this.explosions.forEach(explosion => {
      this.ctx.save();
      
      // Main explosion glow
      const progress = explosion.time / explosion.maxTime;
      const currentRadius = explosion.radius * (1 + (1 - progress) * 0.5);
      
      const gradient = this.ctx.createRadialGradient(
        explosion.x, explosion.y, 0,
        explosion.x, explosion.y, currentRadius
      );
      gradient.addColorStop(0, explosion.color);
      gradient.addColorStop(0.7, `${explosion.color}${Math.floor(progress * 0.7 * 255).toString(16).padStart(2, '0')}`);
      gradient.addColorStop(1, 'transparent');
      
      this.ctx.globalAlpha = progress * 0.8;
      this.ctx.fillStyle = gradient;
      this.ctx.beginPath();
      this.ctx.arc(explosion.x, explosion.y, currentRadius, 0, Math.PI * 2);
      this.ctx.fill();
      
      // Explosion particles
      this.ctx.globalAlpha = progress * 0.6;
      this.ctx.fillStyle = explosion.color;
      for (let i = 0; i < 12; i++) {
        const angle = (i / 12) * Math.PI * 2;
        const distance = (1 - progress) * explosion.radius * (0.7 + Math.random() * 0.3);
        const particleSize = explosion.radius * 0.1 * progress;
        
        this.ctx.beginPath();
        this.ctx.arc(
          explosion.x + Math.cos(angle) * distance,
          explosion.y + Math.sin(angle) * distance,
          particleSize,
          0,
          Math.PI * 2
        );
        this.ctx.fill();
      }
      
      this.ctx.restore();
    });
  }

  drawParticles() {
    this.particles.forEach(particle => {
      this.ctx.save();
      this.ctx.globalAlpha = particle.life / particle.maxLife;
      this.ctx.fillStyle = particle.color;
      this.ctx.beginPath();
      this.ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
      this.ctx.fill();
      this.ctx.restore();
    });
  }

  drawUI() {
    // Draw level indicator
    if (this.level > 1) {
      this.ctx.save();
      this.ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
      this.ctx.font = '20px "Press Start 2P"';
      this.ctx.textAlign = 'right';
      this.ctx.fillText(`LEVEL ${this.level}`, this.width - 20, 30);
      this.ctx.restore();
    }
    
    // Draw score multiplier if high level
    if (this.level > 3) {
      this.ctx.save();
      this.ctx.fillStyle = '#ffff00';
      this.ctx.font = '16px "Press Start 2P"';
      this.ctx.textAlign = 'right';
      this.ctx.fillText(`x${this.level} MULTIPLIER`, this.width - 20, 55);
      this.ctx.restore();
    }
  }
  
  spawnEnemy() {
    const x = Math.random() * (this.width - 40) + 20;
    const y = -50;
    const difficultySettings = this.difficultySettings[this.difficulty];

    const speed = Math.random() * 100 + 50 + (this.level * 10) * difficultySettings.enemySpeed;
    const health = 1 + Math.floor(this.level / 3) * difficultySettings.enemySpeed;

    this.enemies.push(new Enemy(x, y, speed, health, this));
  }
  
  spawnPowerup() {
    if (Math.random() < (this.difficulty === 'Easy' ? 0.5 : this.difficulty === 'Hard' ? 0.2 : 0.35)) {
      const x = Math.random() * (this.width - 30) + 15;
      const y = -30;
      const type = Math.random() < 0.7 ? 'ammo' : 'health';
  
      this.powerups.push(new Powerup(x, y, type, this));
    }
  }
  
  addExplosion(x, y, color = '#ff4500', radius = 30, duration = 500) {
    this.explosions.push({
      x,
      y,
      radius: radius + Math.random() * 20,
      maxRadius: radius,
      time: duration,
      maxTime: duration,
      color
    });
    
    // Add particles for more realistic effect
    this.addParticles(x, y, 15, color, radius * 0.8);
  }

  addParticles(x, y, count, color, maxDistance) {
    for (let i = 0; i < count; i++) {
      this.particles.push({
        x,
        y,
        vx: Math.random() * 6 - 3,
        vy: Math.random() * 6 - 3,
        size: Math.random() * 3 + 1,
        color,
        life: Math.random() * 800 + 200,
        maxLife: 1000
      });
    }
  }
  
  checkCollisions() {
    // Handle bullet collisions with reverse iteration
    for (let bulletIndex = this.bullets.length - 1; bulletIndex >= 0; bulletIndex--) {
        const bullet = this.bullets[bulletIndex];
        let bulletRemoved = false;

        if (bullet.fromPlayer) {
            // Check collisions with enemies (reverse iteration)
            for (let enemyIndex = this.enemies.length - 1; enemyIndex >= 0; enemyIndex--) {
                const enemy = this.enemies[enemyIndex];
                if (this.checkCollision(bullet, enemy)) {
                    enemy.takeDamage(1);
                    this.bullets.splice(bulletIndex, 1);
                    bulletRemoved = true;

                    if (enemy.health <= 0) {
                        this.addExplosion(
                            enemy.x + enemy.width/2, 
                            enemy.y + enemy.height/2,
                            '#ff4500',
                            40,
                            700
                        );
                        this.enemies.splice(enemyIndex, 1);
                        this.score += 10 * this.level;
                    } else {
                        // Small impact effect
                        this.addExplosion(
                            bullet.x, 
                            bullet.y,
                            '#ffffff',
                            15,
                            200
                        );
                    }
                    break; // Exit enemy loop since bullet is destroyed
                }
            }
        } else {
            // Enemy bullet hitting player
            if (this.checkCollision(bullet, this.player)) {
                this.player.takeDamage(10);
                this.bullets.splice(bulletIndex, 1);
                bulletRemoved = true;
                this.addExplosion(
                    bullet.x, 
                    bullet.y, 
                    '#ff0000',
                    25,
                    400
                );
            }
        }

        // Skip further checks if bullet was removed
        if (bulletRemoved) continue;
    }

    // Handle player-enemy collisions
    for (let enemyIndex = this.enemies.length - 1; enemyIndex >= 0; enemyIndex--) {
        const enemy = this.enemies[enemyIndex];
        if (this.checkCollision(this.player, enemy)) {
            this.player.takeDamage(20);
            this.addExplosion(
                enemy.x + enemy.width/2, 
                enemy.y + enemy.height/2,
                '#ff0000',
                50,
                800
            );
            this.enemies.splice(enemyIndex, 1);
        }
    }

    // Handle powerup collisions
    for (let powerupIndex = this.powerups.length - 1; powerupIndex >= 0; powerupIndex--) {
        const powerup = this.powerups[powerupIndex];
        if (this.checkCollision(this.player, powerup)) {
            if (powerup.type === 'health') {
                this.player.health = Math.min(this.player.health + 20, 100);
                this.addExplosion(
                    powerup.x + powerup.width/2, 
                    powerup.y + powerup.height/2, 
                    '#00ff00',
                    30,
                    500
                );
            } else if (powerup.type === 'ammo') {
                this.player.ammo += 15;
                this.addExplosion(
                    powerup.x + powerup.width/2, 
                    powerup.y + powerup.height/2, 
                    '#1e90ff',
                    30,
                    500
                );
            }
            this.powerups.splice(powerupIndex, 1);
        }
    }
}
  
  checkCollision(obj1, obj2) {
    return (
      obj1.x < obj2.x + obj2.width &&
      obj1.x + obj1.width > obj2.x &&
      obj1.y < obj2.y + obj2.height &&
      obj1.y + obj1.height > obj2.y
    );
  }
  
  updateUI() {
    this.scoreElement.textContent = this.score;
    this.healthElement.textContent = this.player.health;
    this.ammoElement.textContent = this.player.ammo;
  }
  
  updateDifficulty() {
    const newLevel = Math.floor(this.score / 500) + 1;
    if (newLevel > this.level) {
      this.level = newLevel;
      this.enemySpawnRate = Math.max(500, 2000 - (this.level * 100));
      
      // Add visual effect when leveling up
      this.addExplosion(
        this.width / 2,
        this.height / 2,
        '#ffff00',
        100,
        1000
      );
    }
  }
  
  gameOver() {
    this.isRunning = false;
    
    // Big explosion effect
    this.addExplosion(
      this.player.x + this.player.width / 2,
      this.player.y + this.player.height / 2,
      '#ff0000',
      100,
      1500
    );
    
    // Show game over screen
    document.getElementById('game-over').classList.remove('hidden');
    document.getElementById('final-score').textContent = this.score;
    
    if (this.onGameOver) {
      this.onGameOver(this.score);
    }
}
}