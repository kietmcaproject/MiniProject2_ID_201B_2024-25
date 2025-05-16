import { Bullet } from './bullet.js';

export class Enemy {
  constructor(x, y, speed, health, game) {
    this.x = x;
    this.y = y;
    this.width = 45;  // Slightly larger for better detail
    this.height = 45;
    this.speed = speed;
    this.health = health;
    this.maxHealth = health;
    this.game = game;
    
    // Enemy behavior properties
    this.shootInterval = Math.random() * 2000 + 1000;
    this.lastShot = 0;
    this.oscillationPhase = Math.random() * Math.PI * 2;
    this.oscillationSpeed = Math.random() * 0.005 + 0.005;
    
    // Enemy types and appearance
    this.type = Math.floor(Math.random() * 3); // 0-2 for different enemy types
    this.frame = 0;
    this.frameTimer = 0;
    this.frameInterval = 200;
    
    // Color schemes for different enemy types
    this.typeColors = [
      { primary: '#ff4d4d', secondary: '#cc0000', engine: '#ff9933' }, // Aggressor
      { primary: '#9933ff', secondary: '#6600cc', engine: '#cc99ff' }, // Interceptor
      { primary: '#33cc33', secondary: '#009900', engine: '#99ff99' }  // Drone
    ];
  }
  
  update(deltaTime) {
    // Vertical movement
    this.y += this.speed * (deltaTime / 1000);
    
    // Horizontal oscillation with smoother movement
    this.oscillationPhase += this.oscillationSpeed;
    this.x += Math.sin(this.oscillationPhase) * 1.5;
    
    // Keep within bounds
    this.x = Math.max(0, Math.min(this.game.width - this.width, this.x));
    
    // Animation frame update
    this.frameTimer += deltaTime;
    if (this.frameTimer > this.frameInterval) {
      this.frame = (this.frame + 1) % 2;
      this.frameTimer = 0;
    }
    
    // Shooting logic
    if (performance.now() - this.lastShot > this.shootInterval) {
      this.shoot();
      this.lastShot = performance.now();
      this.shootInterval = Math.random() * 2000 + 1000; // Randomize next shot
    }
  }
  
  draw(ctx) {
    ctx.save();
    
    const colors = this.typeColors[this.type];
    const centerX = this.x + this.width / 2;
    const centerY = this.y + this.height / 2;
    
    // Draw different enemy types
    switch (this.type) {
      case 0: // Aggressor (angular fighter)
        ctx.fillStyle = this.frame === 0 ? colors.primary : colors.secondary;
        ctx.beginPath();
        ctx.moveTo(centerX, this.y);
        ctx.lineTo(this.x + this.width, this.y + this.height);
        ctx.lineTo(centerX, this.y + this.height * 0.7);
        ctx.lineTo(this.x, this.y + this.height);
        ctx.closePath();
        ctx.fill();
        
        // Engines
        ctx.fillStyle = colors.engine;
        ctx.fillRect(centerX - 8, this.y + this.height * 0.6, 16, 8);
        break;
        
      case 1: // Interceptor (sleek design)
        ctx.fillStyle = colors.primary;
        ctx.beginPath();
        ctx.moveTo(centerX, this.y);
        ctx.bezierCurveTo(
          this.x + this.width, this.y + this.height * 0.3,
          this.x + this.width, this.y + this.height * 0.7,
          centerX, this.y + this.height
        );
        ctx.bezierCurveTo(
          this.x, this.y + this.height * 0.7,
          this.x, this.y + this.height * 0.3,
          centerX, this.y
        );
        ctx.fill();
        
        // Glowing core
        ctx.fillStyle = this.frame === 0 ? '#ffffff' : colors.secondary;
        ctx.beginPath();
        ctx.arc(centerX, centerY, this.width * 0.15, 0, Math.PI * 2);
        ctx.fill();
        break;
        
      case 2: // Drone (mechanical)
        ctx.fillStyle = colors.primary;
        ctx.beginPath();
        ctx.arc(centerX, centerY, this.width * 0.4, 0, Math.PI * 2);
        ctx.fill();
        
        // Mechanical details
        ctx.strokeStyle = colors.secondary;
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.arc(centerX, centerY, this.width * 0.3, 0, Math.PI * 2);
        ctx.stroke();
        ctx.beginPath();
        ctx.moveTo(this.x, centerY);
        ctx.lineTo(this.x + this.width, centerY);
        ctx.moveTo(centerX, this.y);
        ctx.lineTo(centerX, this.y + this.height);
        ctx.stroke();
        
        // Rotating inner circle
        ctx.save();
        ctx.translate(centerX, centerY);
        ctx.rotate(performance.now() * 0.002);
        ctx.beginPath();
        ctx.arc(0, 0, this.width * 0.15, 0, Math.PI * 2);
        ctx.stroke();
        ctx.restore();
        break;
    }
    
    // Draw health bar
    if (this.health < this.maxHealth) {
      const healthWidth = this.width * (this.health / this.maxHealth);
      ctx.fillStyle = '#ff0000';
      ctx.fillRect(this.x, this.y - 12, this.width, 4);
      ctx.fillStyle = '#00ff00';
      ctx.fillRect(this.x, this.y - 12, healthWidth, 4);
    }
    
    ctx.restore();
  }
  
  shoot() {
    const startX = this.x + this.width / 2;
    const startY = this.y + this.height;
    const targetX = this.game.player.x + this.game.player.width / 2;
    const targetY = this.game.player.y;
    
    const bullet = new Bullet(startX, startY, targetX, targetY, false, this.game);
    this.game.bullets.push(bullet);
    
    // Add muzzle flash effect
    this.game.addExplosion(
      startX,
      startY - 5,
      this.typeColors[this.type].engine,
      15,
      150
    );
  }
  
  takeDamage(amount) {
    this.health -= amount;
    
    // Show hit effect
    this.game.addExplosion(
      this.x + this.width / 2,
      this.y + this.height / 2,
      '#ff0000',
      15,
      200
    );
  }
}