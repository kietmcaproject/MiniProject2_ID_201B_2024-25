export class Bounty {
  constructor(x, y, type) {
    this.x = x;
    this.y = y;
    this.type = type; // "health" or "ammo"
    this.width = 30;
    this.height = 30;
    this.speed = 1;
    this.collected = false;
    this.image = new Image();
    this.image.src = `assets/bounty-${type}.jpg`; // Add bounty-health.png and bounty-ammo.png
  }

  update() {
    this.x -= this.speed;
  }

  draw(ctx) {
    ctx.drawImage(this.image, this.x, this.y, this.width, this.height);
  }

  applyEffect(player) {
    if (this.type === "health") {
      player.health = Math.min(player.maxHealth, player.health + 20);
    } else if (this.type === "ammo") {
      player.ammo += 5;
    }
    this.collected = true;
  }
}
