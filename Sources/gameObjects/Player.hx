package gameObjects;

import com.soundLib.SoundManager.SM;
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
	var body:Sprite;

	var bed:Sprite;

	var directionDisplay:Sprite;

	var maxSpeed = 100;
	var lastFloorTouch:Float = 0;
	var preJumpStart:Float = 100;

	inline static var coyoteTime:Float = 0.1;
	inline static var preJumpMaxTime:Float = 0.1;

	var throwDirection:FastVector2;

	var pickObject:WoodLog;
	var throwMode:Bool = false;

	var lastWalkPos:Float=0;

	public function new(layer:Layer,bed:Bool=false) {
		super();
		throwDirection = new FastVector2(0, 0);
		display = new Layer();
		if(bed){
			display.visible=false;
			this.bed=new Sprite("bed");
			this.bed.smooth=false;
			this.bed.timeline.stop();
			layer.addChild(this.bed);
		}
		body = new Sprite("player");
		display.addChild(body);
		body.smooth = false;
		display.pivotX = body.width() * 0.5;
		display.pivotY = body.height();
		layer.addChild(display);

		directionDisplay = new Sprite("direction");
		directionDisplay.smooth = false;
		directionDisplay.visible = false;
		directionDisplay.pivotY = directionDisplay.height() * 0.5;
		layer.addChild(directionDisplay);

		collision = new CollisionBox();
		collision.width = body.width();
		collision.height = body.height();
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
		if(bed!=null){
			return;
		}
		if (throwMode&&pickObject!=null) {
			dt *= 0.2;
		}
		super.update(dt);
		
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
		if(collision.isTouching(Sides.BOTTOM)&&Math.abs(lastWalkPos-collision.x)>10){
			lastWalkPos=collision.x;
			SM.playFx("walk");
		}
		preJumpStart += dt;
		collision.update(dt);

		
	}

	override function render() {
		if(bed!=null){
			bed.x=collision.x;
			bed.y=collision.y;
		}
		display.x = collision.x;
		display.y = collision.y;
		super.render();
		if(pickObject!=null){
			body.timeline.playAnimation("armsUp");
		}else{
			body.timeline.playAnimation("idle");
		}
		if (throwMode&&pickObject!=null) {
			directionDisplay.visible = true;
			directionDisplay.x = collision.x+collision.width*0.5;
			directionDisplay.y = collision.y;
			var direction=new FastVector2(throwDirection.x,throwDirection.y);
			adjustEmptyDirection(direction);
			directionDisplay.rotation = Math.atan2(direction.y, direction.x);
		} else {
			directionDisplay.visible = false;
		}
		if (collision.velocityX != 0 && collision.isTouching(Sides.BOTTOM)) {
			display.rotation = Math.PI / 20 * Math.sin(TimeManager.time * 20);
		} else {
			display.rotation = 0;
		}
		var s = Math.abs(collision.velocityY) / collision.maxVelocityY;
		display.scaleY = LERP.f(1, 1.3, s);
		if(display.scaleY>1.3)display.scaleY=1.3;
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
				if(bed!=null){
					bed.timeline.playAnimation("out");
					display.visible=true;
					bed=null;
				}
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
					var direction=new FastVector2(throwDirection.x,throwDirection.y);
					adjustEmptyDirection(direction);
					direction.setFrom(direction.normalized());

					pickObject.shoot(collision.x, collision.y, direction);
					if(Math.abs(direction.x)!=1){
						collision.velocityX=collision.maxVelocityX*direction.x;
						collision.velocityY=collision.maxVelocityY*-direction.y;
						collision.accelerationX=collision.maxVelocityX*direction.x;
					}
					SM.playFx("throwWood");
					pickObject = null;
				}
			}
		}
	}

	public function jump() {
		if (collision.isTouching(Sides.BOTTOM) || (lastFloorTouch < coyoteTime && !isWallGrabing())) {
			collision.velocityY = -600;
			SM.playFx("jump");
		} else if (isWallGrabing()) {
			if (collision.isTouching(Sides.LEFT)) {
				collision.velocityX = 200;
			} else {
				collision.velocityX = -200;
			}
			collision.velocityY = -600;
			SM.playFx("jump");
		}
	}

	public inline function canJump() {
		return collision.isTouching(Sides.BOTTOM) || (lastFloorTouch < coyoteTime && !isWallGrabing()) || isWallGrabing();
	}

	public function onAxisChange(id:Int, value:Float) {}

	inline function adjustEmptyDirection(vector:FastVector2) {
		if(vector.x == 0 && vector.y == 0){
			vector.setFrom(new FastVector2(-display.scaleX, 0));
		}
	}
}
