package gameObjects;

import com.framework.utils.LERP;
import com.framework.utils.Random;
import com.soundLib.SoundManager.SM;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionGroup;
import com.gEngine.display.Sprite;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

class FirePlace extends Entity {
	public var collision:CollisionBox;
	public var display:Sprite;
	var layer:Layer;
	var shakeTime:Float=0;
	var shakeTotalTime:Float=0.5;

	public function new(layer:Layer, collisions:CollisionGroup) {
		super();
		this.layer=layer;
		display = new Sprite("firePlace");
		display.smooth=false;
		display.pivotX=display.width()*0.5;
		display.pivotY=display.height()*0.5;
		layer.addChild(display);
		collision = new CollisionBox();
		collision.userData=this;
		collision.width = display.width();
		collision.height = display.height();
		collisions.add(collision);
	}
	override function update(dt:Float) {
		super.update(dt);
		if(shakeTime>0){
			shakeTime-=dt;
			var s=shakeTime/shakeTotalTime;
			display.colorAdd(s,s,s);
			display.scaleX=display.scaleY=LERP.f(1,1.2,s);
			display.rotation=(s*Math.PI/16)*Random.getRandomIn(-1,1);
			
		}
	}
	override function render() {

		display.x = collision.x;
		display.y = collision.y;
	}
	public function start() {
		shakeTime = shakeTotalTime;
		var fire=new Sprite("fire");
		fire.smooth=false;
		fire.x=collision.x+10;
		fire.y=collision.y+9;
		layer.addChild(fire);
		SM.playFx("score");
	}
}
