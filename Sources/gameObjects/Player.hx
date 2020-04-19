package gameObjects;

import kha.math.FastVector2;
import com.framework.utils.LERP;
import com.TimeManager;
import com.collision.platformer.Sides;
import com.framework.utils.XboxJoystick;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class Player extends Entity {
	public var display:Layer;
	public var collision:CollisionBox;

	var directionDisplay:Sprite;

	var maxSpeed = 100;
	var lastFloorTouch:Float = 0;
	var preJumpStart:Float = 100;

	inline static var coyoteTime:Float = 0.1;
	inline static var preJumpMaxTime:Float = 0.1;

	var throwDirection:FastVector2;

	var pickObject:WoodLog;
	var throwMode:Bool = false;

	public function new(layer:Layer) {
		super();
		throwDirection = new FastVector2(0, 1);
		display = new Layer();
		var sprite = new Sprite("player");
		display.addChild(sprite);
		sprite.smooth = false;
		display.pivotX = sprite.width() * 0.5;
		display.pivotY = sprite.height();
		layer.addChild(display);

		directionDisplay = new Sprite("direction");
		directionDisplay.smooth = false;
		directionDisplay.visible = false;
		directionDisplay.offsetY = directionDisplay.height() * 0.5;
		layer.addChild(directionDisplay);

		collision = new CollisionBox();
		collision.width = sprite.width();
		collision.height = sprite.height();
		collision.maxVelocityX = 500;
		// display.offsetX = -display.width()*0.5;
		// display.offsetY = -display.height()*0.5;
		display.scaleX = display.scaleY = 1;

		collision.userData = this;
		collision.accelerationY = GameGlobals.Gravity;
		collision.maxVelocityY = 200;
		collision.maxVelocityX = 150;
		collision.dragX = 0.9;

		collision.width = 7;
		collision.height = 8;
		display.offsetX = -2;
		display.offsetY = -3;
	}

	public function pickUp(wood:WoodLog) {
		if(wood.pickedUp(display)){
			pickObject = wood;
			if(wood.collision.velocityY<0&&!collision.isTouching(Sides.BOTTOM)){
				collision.velocityY=wood.collision.velocityY*10;
			}
		}
	}

	override function update(dt:Float) {
		if (throwMode&&pickObject!=null) {
			dt *= 0.2;
		}
		super.update(dt);
		display.x = collision.x;
		display.y = collision.y;
		var s = Math.abs(collision.velocityX / collision.maxVelocityX);
		// display.timeline.frameRate = (1 / 24) * s + (1 - s) * (1 / 10);
		if (collision.isTouching(Sides.BOTTOM)) {
			lastFloorTouch = 0;
		} else {
			lastFloorTouch += dt;
		}

		if (preJumpStart < preJumpMaxTime && canJump()) {
			jump();
		}
		preJumpStart += dt;
		collision.update(dt);
	}

	override function render() {
		super.render();
		if (throwMode&&pickObject!=null) {
			directionDisplay.visible = true;
			directionDisplay.x = collision.x+collision.width*0.5;
			directionDisplay.y = collision.y+collision.height*0.5;
			adjustEmptyDirection();
			directionDisplay.rotation = Math.atan2(throwDirection.y, throwDirection.x);
		} else {
			directionDisplay.visible = false;
		}
		if (collision.velocityX != 0 && collision.isTouching(Sides.BOTTOM)) {
			display.rotation = Math.PI / 20 * Math.sin(TimeManager.time * 20);
		} else {
			display.rotation = 0;
		}
		var s = Math.abs(collision.velocityY) / collision.maxVelocityY;
		display.scaleY = LERP.f(1, 1.2, s);
		if (display.scaleX < 0) {
			display.scaleX = -1 / display.scaleY;
		} else {
			display.scaleX = 1 / display.scaleY;
		}
		if (!collision.isTouching(Sides.BOTTOM)) {
			display.rotation = Math.atan2(collision.velocityY, Math.abs(collision.velocityX));
			if (display.scaleX > 0) {
				display.rotation *= -1;
			}
			if (display.rotation > Math.PI / 20) {
				display.rotation = Math.PI / 20;
			} else if (display.rotation < -Math.PI / 20) {
				display.rotation = -Math.PI / 20;
			}
		}
	}

	inline function isWallGrabing():Bool {
		return !collision.isTouching(Sides.BOTTOM) && (collision.isTouching(Sides.LEFT) || collision.isTouching(Sides.RIGHT));
	}

	public function onButtonChange(id:Int, value:Float) {
		if (id == XboxJoystick.LEFT_DPAD) {
			if (value == 1) {
				throwDirection.x = -1;
			} else {
				if (throwDirection.x < 0)
					throwDirection.x = 0;
			}

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
				throwDirection.x = 1;
			} else {
				if (throwDirection.x > 0)
					throwDirection.x = 0;
			}

			if (value == 1) {
				collision.accelerationX = maxSpeed * 4;
				display.scaleX = -Math.abs(display.scaleX);
			} else {
				if (collision.accelerationX > 0) {
					collision.accelerationX = 0;
				}
			}
		}
		if (id == XboxJoystick.UP_DPAD) {
			if (value == 1) {
				throwDirection.y = -1;
			} else {
				if (throwDirection.y <0)
					throwDirection.y = 0;
			}
		}
		if (id == XboxJoystick.DOWN_DPAD) {
			if (value == 1) {
				throwDirection.y = 1;
			} else {
				if (throwDirection.y >0)
					throwDirection.y = 0;
			}
		}
		if (id == XboxJoystick.A) {
			if (value == 1) {
				if (canJump()) {
					jump();
				} else {
					preJumpStart = 0;
				}
			}
		}
		if (id == XboxJoystick.X) {
			if (value == 1) {
				
				throwMode = true;
				
			} else {
				throwMode = false;

				if (pickObject != null) {
					adjustEmptyDirection();
					throwDirection.setFrom(throwDirection.normalized());

					pickObject.shoot(collision.x, collision.y, throwDirection);
					if(Math.abs(throwDirection.x)!=1){
						collision.velocityX=collision.maxVelocityX*throwDirection.x;
						collision.velocityY=collision.maxVelocityY*-throwDirection.y;
						collision.accelerationX=collision.maxVelocityX*throwDirection.x;
					}
					pickObject = null;
				}
			}
		}
	}

	public function jump() {
		if (collision.isTouching(Sides.BOTTOM) || (lastFloorTouch < coyoteTime && !isWallGrabing())) {
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

	public inline function canJump() {
		return collision.isTouching(Sides.BOTTOM) || (lastFloorTouch < coyoteTime && !isWallGrabing()) || isWallGrabing();
	}

	public function onAxisChange(id:Int, value:Float) {}
	function adjustEmptyDirection() {
		if (throwDirection.x == 0 && throwDirection.y == 0) {
			throwDirection.setFrom(new FastVector2(-display.scaleX, 0));
		}
	}
}
