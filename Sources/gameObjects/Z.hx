package gameObjects;

import com.framework.utils.LERP;
import kha.math.FastVector2;
import com.framework.utils.Random;
import com.gEngine.display.Layer;
import com.helpers.MinMax;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class Z extends Entity {
	var display:Sprite;
	var speed:Float = 0;
	var time:Float = 0;
	var totalTime = 3;
	var initialX:Float;
	var initialY:Float;

	public function new(layer:Layer, x:Float, y:Float, s:Float) {
		display = new Sprite("z");
		display.smooth = false;
		layer.addChild(display);

		initialX = x;
		initialY = y;

		display.x = x;
		display.y = y;
		super();
		update(totalTime * s);
	}

	override function update(dt:Float) {
		time += dt;
		
		if (time > totalTime) {
			time = 0;
			display.x = initialX;
            display.y = initialY;
            
        }
        totalTime=3;
        speed = 10;
        var velX=Math.sin(time*4) * 5 * dt;
        var velY=speed * dt;
		display.x += velX;
        display.y -= velY;
        var angle=-Math.atan2(velY,velX)*0.1;
        display.rotation=angle;
        var s = time/totalTime;
        display.alpha=LERP.f(1,0,s);
        display.scaleX=display.scaleY=LERP.f(0.1,1.4,s);
    }
    override function destroy() {
        super.destroy();
        display.removeFromParent();
    }
}
