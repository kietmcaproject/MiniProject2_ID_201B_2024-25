export class Bullet {
  constructor(startX, startY, targetX, targetY, fromPlayer, game) {
    this.x = startX;
    this.y = startY;
    this.width = fromPlayer ? 6 : 8;
    this.height = fromPlayer ? 20 : 15;
    this.speed = fromPlayer ? 800 : 400;
    this.fromPlayer = fromPlayer;
    this.game = game;
    this.lifetime = 2000;
    this.createdTime = performance.now();
    this.active = true; // Add active flag
    
    // Calculate direction
    const angle = Math.atan2(targetY - startY, targetX - startX);
    const spread = fromPlayer ? 0 : (Math.random() - 0.5) * 0.1;
    this.velocityX = Math.cos(angle + spread) * this.speed;
    this.velocityY = Math.sin(angle + spread) * this.speed;

    this.trail = [];
    this.maxTrailLength = 15;
    this.sparkIntensity = 0;
  }

  update(deltaTime) {
    if (!this.active) return; // Skip if inactive
    
    this.trail.push({ x: this.x, y: this.y });
    if (this.trail.length > this.maxTrailLength) {
      this.trail.shift();
    }

    this.x += this.velocityX * (deltaTime / 1000);
    this.y += this.velocityY * (deltaTime / 1000);

    this.sparkIntensity = Math.max(0, this.sparkIntensity - deltaTime * 0.002);

    // Mark inactive instead of calling removeBullet
    if (performance.now() - this.createdTime > this.lifetime ||
        this.y < 0 || this.y > this.game.height || 
        this.x < 0 || this.x > this.game.width) {
      this.active = false;
    }
  }
  draw(ctx) {
    ctx.save();
    
    // Calculate bullet rotation angle
    const angle = Math.atan2(this.velocityY, this.velocityX) + Math.PI/2;
    
    // Draw bullet trail
    this.drawTrail(ctx);
    
    // Draw bullet glow
    this.drawGlowEffect(ctx);
    
    // Draw bullet core
    ctx.translate(this.x, this.y);
    ctx.rotate(angle);
    
    if (this.fromPlayer) {
      this.drawPlayerBullet(ctx);
    } else {
      this.drawEnemyBullet(ctx);
    }
    
    // Draw muzzle spark if recently fired
    if (this.sparkIntensity > 0) {
      this.drawMuzzleSpark(ctx);
    }
    
    ctx.restore();
  }

  drawTrail(ctx) {
    // Only draw trail for fast-moving bullets
    if (Math.abs(this.velocityX) + Math.abs(this.velocityY) > 500) {
      ctx.strokeStyle = this.fromPlayer ? 
        `rgba(100, 255, 255, 0.3)` : 
        `rgba(255, 100, 100, 0.3)`;
      ctx.lineWidth = this.width * 0.8;
      
      ctx.beginPath();
      for (let i = 0; i < this.trail.length - 1; i++) {
        const p1 = this.trail[i];
        const p2 = this.trail[i + 1];
        ctx.moveTo(p1.x + this.width/2, p1.y + this.height/2);
        ctx.lineTo(p2.x + this.width/2, p2.y + this.height/2);
      }
      ctx.stroke();
    }
  }

  drawGlowEffect(ctx) {
    const gradient = ctx.createRadialGradient(
      this.x + this.width/2, 
      this.y + this.height/2, 
      0,
      this.x + this.width/2, 
      this.y + this.height/2, 
      this.width * 4
    );
    
    gradient.addColorStop(0, this.fromPlayer ? 'rgba(0, 255, 255, 0.8)' : 'rgba(255, 50, 50, 0.8)');
    gradient.addColorStop(0.7, this.fromPlayer ? 'rgba(0, 150, 255, 0.2)' : 'rgba(255, 0, 0, 0.2)');
    gradient.addColorStop(1, 'transparent');
    
    ctx.fillStyle = gradient;
    ctx.fillRect(
      this.x - this.width * 2, 
      this.y - this.height, 
      this.width * 5, 
      this.height * 3
    );
  }

  drawPlayerBullet(ctx) {
    // Plasma core
    const plasmaGradient = ctx.createLinearGradient(0, -this.height/2, 0, this.height/2);
    plasmaGradient.addColorStop(0, '#00ffff');
    plasmaGradient.addColorStop(0.5, '#0066ff');
    plasmaGradient.addColorStop(1, '#00ffff');
    
    ctx.fillStyle = plasmaGradient;
    ctx.beginPath();
    ctx.moveTo(0, -this.height/2);
    ctx.lineTo(-this.width/2, this.height/4);
    ctx.lineTo(0, this.height/2);
    ctx.lineTo(this.width/2, this.height/4);
    ctx.closePath();
    ctx.fill();
    
    // Energy outline
    ctx.strokeStyle = 'rgba(200, 255, 255, 0.8)';
    ctx.lineWidth = 1.5;
    ctx.stroke();
  }

  drawEnemyBullet(ctx) {
    // Projectile core
    const coreGradient = ctx.createRadialGradient(
      0, 0, 0,
      0, 0, this.width/2
    );
    coreGradient.addColorStop(0, '#ff5555');
    coreGradient.addColorStop(1, '#ff0000');
    
    ctx.fillStyle = coreGradient;
    ctx.beginPath();
    ctx.arc(0, 0, this.width/2, 0, Math.PI * 2);
    ctx.fill();
    
    // Burning effect
    ctx.strokeStyle = 'rgba(255, 150, 0, 0.7)';
    ctx.lineWidth = 2;
    ctx.beginPath();
    for (let i = 0; i < 8; i++) {
      const angle = (i / 8) * Math.PI * 2;
      const length = this.width * (0.3 + Math.random() * 0.3);
      ctx.moveTo(0, 0);
      ctx.lineTo(
        Math.cos(angle) * length,
        Math.sin(angle) * length
      );
    }
    ctx.stroke();
  }

  drawMuzzleSpark(ctx) {
    const sparkSize = this.width * 3 * this.sparkIntensity;
    const sparkGradient = ctx.createRadialGradient(
      0, -this.height/2, 0,
      0, -this.height/2, sparkSize
    );
    sparkGradient.addColorStop(0, 'rgba(255, 255, 255, 0.9)');
    sparkGradient.addColorStop(0.7, 'rgba(255, 200, 0, 0.5)');
    sparkGradient.addColorStop(1, 'transparent');
    
    ctx.fillStyle = sparkGradient;
    ctx.beginPath();
    ctx.arc(0, -this.height/2, sparkSize, 0, Math.PI * 2);
    ctx.fill();
  }

  // Called when bullet is first fired
  triggerMuzzleSpark() {
    this.sparkIntensity = 1;
  }
}