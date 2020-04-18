package gameObjects;

import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class Player extends Entity {
	public var display:Sprite;
	public var collision:CollisionBox;

	var maxSpeed = 100;

	public function new(layer:Layer) {
		super();
		display = new Sprite("player");
		display.smooth = false;
		layer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height()*0.5;
		collision.maxVelocityX = 500;
		display.offsetX = -display.width()*0.5;
		display.offsetY = -display.height()*0.5;
		display.scaleX = display.scaleY = 1;

		collision.userData = this;
		collision.accelerationY = GameGlobals.Gravity;
		collision.maxVelocityY = 300;
		collision.maxVelocityX = 150;
		collision.dragX = 0.9;
	}

	override function update(dt:Float) {
		super.update(dt);
		display.x = collision.x+display.width()*0.5;
		display.y = collision.y;
	/*	if (isWallGrabing()) {
			display.timeline.playAnimation("wallGrab");
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX * collision.accelerationX < 0) {
			display.timeline.playAnimation("slide");
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX == 0) {
			display.timeline.playAnimation("idle");
		} else if (collision.isTouching(Sides.BOTTOM) && collision.velocityX != 0) {
			display.timeline.playAnimation("run");
		} else if (!collision.isTouching(Sides.BOTTOM) && collision.velocityY > 0) {
			display.timeline.playAnimation("fall");
		} else if (!collision.isTouching(Sides.BOTTOM) && collision.velocityY < 0) {
			display.timeline.playAnimation("jump");
		}*/
		var s = Math.abs(collision.velocityX / collision.maxVelocityX);
		display.timeline.frameRate = (1 / 24) * s + (1 - s) * (1 / 10);
		collision.update(dt);
	}

	inline function isWallGrabing():Bool {
		return !collision.isTouching(Sides.BOTTOM) && (collision.isTouching(Sides.LEFT) || collision.isTouching(Sides.RIGHT));
	}

	public function onButtonChange(id:Int, value:Float) {
		if (id == XboxJoystick.LEFT_DPAD) {
			if (value == 1) {
				collision.accelerationX = -maxSpeed * 4;
				display.scaleX = Math.abs(display.scaleX);
			} else {
				if (collision.accelerationX < 0) {
					collision.accelerationX = 0;
				}
			}
		}
		if (id == XboxJoystick.RIGHT_DPAD) {
			if (value == 1) {
				collision.accelerationX = maxSpeed * 4;
				display.scaleX = -Math.abs(display.scaleX);
			} else {
				if (collision.accelerationX > 0) {
					collision.accelerationX = 0;
				}
			}
		}
		if (id == XboxJoystick.A) {
			if (value == 1) {
				if (collision.isTouching(Sides.BOTTOM)) {
					collision.velocityY = -600;
				} else if (isWallGrabing()) {
					if (collision.isTouching(Sides.LEFT)) {
						collision.velocityX = 200;
					} else {
						collision.velocityX = -200;
					}
					collision.velocityY = -600;
				}
			}
		}
	}

	public function onAxisChange(id:Int, value:Float) {}
}
