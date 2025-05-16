import { Bullet } from './bullet.js';

export class Player {
  constructor(x, y, game) {
    this.x = x;
    this.y = y;
    this.width = 50;  // Slightly larger for better detail
    this.height = 60;
    this.speed = 300;
    this.health = 100;
    this.ammo = 30;
    this.reloadTime = 1500;
    this.isReloading = false;
    this.reloadStart = 0;
    this.game = game;
    
    // Enhanced ship design properties
    this.thrusterAnimation = {
      frames: [10, 15, 20], // Thruster flame sizes
      currentFrame: 0,
      timer: 0,
      interval: 100 // ms between frames
    };
    this.shipTilt = 0; // For banking animation
    this.maxTilt = 0.3; // Max tilt in radians
    
    // Ship colors
    this.primaryColor = '#4a5af8';
    this.secondaryColor = '#2a3bd8';
    this.cockpitColor = '#a0f8ff';
    this.thrusterColors = ['#ff6b00', '#ff9548', '#ffb56b'];
  }
  
  update(deltaTime, keys) {
    // Movement (keeping your exact control scheme)
    const moveDistance = this.speed * (deltaTime / 1000);
    
    // Update banking tilt
    if (keys['ArrowLeft'] || keys['KeyA']) {
      this.x = Math.max(0, this.x - moveDistance);
      this.shipTilt = Math.max(-this.maxTilt, this.shipTilt - 0.05);
    } else if (keys['ArrowRight'] || keys['KeyD']) {
      this.x = Math.min(this.game.width - this.width, this.x + moveDistance);
      this.shipTilt = Math.min(this.maxTilt, this.shipTilt + 0.05);
    } else {
      // Return to level when not moving sideways
      this.shipTilt *= 0.9;
    }
    
    if (keys['ArrowUp'] || keys['KeyW']) {
      this.y = Math.max(0, this.y - moveDistance);
    }
    if (keys['ArrowDown'] || keys['KeyS']) {
      this.y = Math.min(this.game.height - this.height, this.y + moveDistance);
    }
    
    // Update thruster animation
    this.thrusterAnimation.timer += deltaTime;
    if (this.thrusterAnimation.timer > this.thrusterAnimation.interval) {
      this.thrusterAnimation.currentFrame = 
        (this.thrusterAnimation.currentFrame + 1) % this.thrusterAnimation.frames.length;
      this.thrusterAnimation.timer = 0;
    }
    
    // Shooting (unchanged)
    if (keys['Space'] && !this.isReloading && this.ammo > 0) {
      this.shoot(this.x + this.width / 2, 0);
    }
    
    // Reloading (unchanged)
    if (keys['KeyR'] && !this.isReloading && this.ammo < 30) {
      this.startReload();
    }
    
    if (this.isReloading && performance.now() - this.reloadStart > this.reloadTime) {
      this.ammo = 30;
      this.isReloading = false;
    }
  }
  
  draw(ctx) {
    ctx.save();
    
    // Apply ship tilt
    ctx.translate(this.x + this.width / 2, this.y + this.height / 2);
    ctx.rotate(this.shipTilt);
    ctx.translate(-(this.x + this.width / 2), -(this.y + this.height / 2));
    
    // Draw advanced ship design
    this.drawShipBody(ctx);
    this.drawThrusters(ctx);
    this.drawCockpit(ctx);
    
    // Draw reload indicator if reloading
    if (this.isReloading) {
      const progress = (performance.now() - this.reloadStart) / this.reloadTime;
      ctx.fillStyle = 'rgba(255, 255, 255, 0.5)';
      ctx.fillRect(this.x, this.y - 15, this.width * progress, 4);
    }
    
    ctx.restore();
  }
  
  drawShipBody(ctx) {
    // Main hull
    ctx.fillStyle = this.primaryColor;
    ctx.beginPath();
    ctx.moveTo(this.x + this.width * 0.5, this.y);
    ctx.lineTo(this.x + this.width * 0.8, this.y + this.height * 0.7);
    ctx.lineTo(this.x + this.width, this.y + this.height);
    ctx.lineTo(this.x, this.y + this.height);
    ctx.lineTo(this.x + this.width * 0.2, this.y + this.height * 0.7);
    ctx.closePath();
    ctx.fill();
    
    // Ship details
    ctx.strokeStyle = this.secondaryColor;
    ctx.lineWidth = 2;
    ctx.beginPath();
    ctx.moveTo(this.x + this.width * 0.5, this.y + this.height * 0.3);
    ctx.lineTo(this.x + this.width * 0.5, this.y + this.height * 0.7);
    ctx.stroke();
  }
  
  drawThrusters(ctx) {
    const flameSize = this.thrusterAnimation.frames[this.thrusterAnimation.currentFrame];
    const thrusterColor = this.thrusterColors[this.thrusterAnimation.currentFrame];
    
    // Main thruster
    ctx.fillStyle = thrusterColor;
    ctx.beginPath();
    ctx.moveTo(this.x + this.width * 0.4, this.y + this.height);
    ctx.lineTo(this.x + this.width * 0.6, this.y + this.height);
    ctx.lineTo(this.x + this.width * 0.5, this.y + this.height + flameSize);
    ctx.closePath();
    ctx.fill();
    
    // Side thrusters (only when moving sideways)
    if (this.shipTilt < -0.1) { // Moving left
      ctx.beginPath();
      ctx.moveTo(this.x + this.width, this.y + this.height * 0.6);
      ctx.lineTo(this.x + this.width + 8, this.y + this.height * 0.6);
      ctx.lineTo(this.x + this.width + 4, this.y + this.height * 0.7);
      ctx.closePath();
      ctx.fill();
    } else if (this.shipTilt > 0.1) { // Moving right
      ctx.beginPath();
      ctx.moveTo(this.x, this.y + this.height * 0.6);
      ctx.lineTo(this.x - 8, this.y + this.height * 0.6);
      ctx.lineTo(this.x - 4, this.y + this.height * 0.7);
      ctx.closePath();
      ctx.fill();
    }
  }
  
  drawCockpit(ctx) {
    // Cockpit glass
    ctx.fillStyle = this.cockpitColor;
    ctx.beginPath();
    ctx.arc(this.x + this.width * 0.5, this.y + this.height * 0.3, this.width * 0.15, 0, Math.PI * 2);
    ctx.fill();
    
    // Cockpit frame
    ctx.strokeStyle = '#000';
    ctx.lineWidth = 1.5;
    ctx.stroke();
  }
  
  // The rest of your methods remain exactly the same
  shoot(targetX, targetY) {
    if (this.ammo <= 0 || this.isReloading) return;
    
    const startX = this.x + this.width / 2;
    const startY = this.y;
    
    const bullet = new Bullet(startX, startY, targetX, targetY, true, this.game);
    this.game.bullets.push(bullet);
    
    this.ammo--;
    
    if (this.ammo === 0) {
      this.startReload();
    }
  }
  
  startReload() {
    this.isReloading = true;
    this.reloadStart = performance.now();
  }
  
  takeDamage(amount) {
    this.health = Math.max(0, this.health - amount);
  }
}