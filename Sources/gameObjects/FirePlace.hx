package gameObjects;

import com.gEngine.display.Layer;
import com.collision.platformer.CollisionGroup;
import com.gEngine.display.Sprite;
import com.collision.platformer.CollisionBox;
import com.framework.utils.Entity;

class FirePlace extends Entity {
	public var collision:CollisionBox;
	public var display:Sprite;

	public function new(layer:Layer, collisions:CollisionGroup) {
		super();
		display = new Sprite("firePlace");
		display.smooth=false;
		layer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height();
		collisions.add(collision);
	}

	override function render() {
		display.x = collision.x;
		display.y = collision.y;
	}
}
