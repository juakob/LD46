package gameObjects;

import com.framework.utils.LERP;
import com.TimeManager;
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
	var lastFloorTouch:Float=0;
	var preJumpStart:Float=100;
	
	inline static var coyoteTime:Float=0.1;
	inline static var preJumpMaxTime:Float=0.1;

	public function new(layer:Layer) {
		super();
		display = new Sprite("player");
		display.smooth = false;
		display.pivotX=display.width()*0.5;
		display.pivotY=display.height();
		layer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height();
		collision.maxVelocityX = 500;
		//display.offsetX = -display.width()*0.5;
		//display.offsetY = -display.height()*0.5;
		display.scaleX = display.scaleY = 1;

		collision.userData = this;
		collision.accelerationY = GameGlobals.Gravity;
		collision.maxVelocityY = 200;
		collision.maxVelocityX = 150;
		collision.dragX = 0.9;

		collision.width=7;
		collision.height=8;
		display.offsetX=-9;
		display.offsetY=-10;
		
	}

	override function update(dt:Float) {
		
		
		super.update(dt);
		display.x = collision.x;
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
		if(collision.isTouching(Sides.BOTTOM)){
			lastFloorTouch=0;
		}else{
			lastFloorTouch+=dt;
		}

		if(preJumpStart<preJumpMaxTime && canJump()){
			jump();
		}
		preJumpStart+=dt;
		collision.update(dt);
	}

	override function render() {
		super.render();
		if(collision.velocityX!=0 && collision.isTouching(Sides.BOTTOM)){
            display.rotation=Math.PI/20*Math.sin(TimeManager.time*20);
       }else{
		   display.rotation=0;
	   }
	   var s=Math.abs(collision.velocityY)/collision.maxVelocityY;
	   display.scaleY=LERP.f(1,1.2,s);
	   if(display.scaleX<0){
			display.scaleX=-1/display.scaleY;
	   }else{
			display.scaleX=1/display.scaleY;
	   }
	   if(!collision.isTouching(Sides.BOTTOM)){
			display.rotation=Math.atan2(collision.velocityY,Math.abs(collision.velocityX));
			if(display.scaleX>0){
				display.rotation*=-1;
			}
			if(display.rotation>Math.PI/20){
				display.rotation=Math.PI/20;
			}else
			if(display.rotation<-Math.PI/20){
				display.rotation=- Math.PI/20;
			}
	   }
	   
	   
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
				if(canJump()){
					jump();
				}else{
					preJumpStart=0;
				}
			}
		}
	}
	public function jump() {
		if (collision.isTouching(Sides.BOTTOM)||(lastFloorTouch<coyoteTime&&!isWallGrabing())) {
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
		return collision.isTouching(Sides.BOTTOM)||(lastFloorTouch<coyoteTime&&!isWallGrabing())||isWallGrabing();
	}

	public function onAxisChange(id:Int, value:Float) {}
}
