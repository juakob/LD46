package gameObjects;

import com.gEngine.display.Layer;
import com.collision.platformer.CollisionGroup;
import com.gEngine.display.Sprite;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

class FirePlace extends Entity {
	public var collision:CollisionBox;
	public var display:Sprite;
	var layer:Layer;

	public function new(layer:Layer, collisions:CollisionGroup) {
		super();
		this.layer=layer;
		display = new Sprite("firePlace");
		display.smooth=false;
		layer.addChild(display);
		collision = new CollisionBox();
		collision.userData=this;
		collision.width = display.width();
		collision.height = display.height();
		collisions.add(collision);
	}

	override function render() {
		display.x = collision.x;
		display.y = collision.y;
	}
	public function start() {
		var fire=new Sprite("fire");
		fire.smooth=false;
		fire.x=collision.x+10;
		fire.y=collision.y+9;
		layer.addChild(fire);
	}
}
