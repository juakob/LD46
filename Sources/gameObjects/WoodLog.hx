package gameObjects;

import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class WoodLog extends Entity {
	var display:Sprite;
	var collision:CollisionBox;

	public function new(layer:Layer) {
		super();
		display = new Sprite("wood");
		collision = new CollisionBox();
		collision.width = display.width();
		collision.height = display.height();
		collision.userData = this;
	}

	override function update(dt:Float) {
		super.update(dt);
		collision.update(dt);
	}

	override function render() {
		super.render();
		display.x = collision.x;
		display.y = collision.y;
	}
}
