package gameObjects;

import com.soundLib.SoundManager.SM;
import kha.math.FastVector2;
import com.collision.platformer.CollisionGroup;
import com.collision.platformer.Sides;
import com.gEngine.display.Layer;
import com.collision.platformer.CollisionBox;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class WoodLog extends Entity {
	var display:Sprite;
    public var collision:CollisionBox;
    var picked:Bool=false;
    var collisionGroup:CollisionGroup;
    var reAddDelay:Float=0;
    var baseLayer:Layer;
    var canBePick:Bool=true;

	public function new(layer:Layer,collisions:CollisionGroup) {
        super();
        collisionGroup=collisions;
        baseLayer=layer;
        display = new Sprite("wood");
        display.smooth=false;
        layer.addChild(display);
		collision = new CollisionBox();
		collision.width = display.width();
        collision.height = display.height();
        collision.accelerationY=GameGlobals.Gravity;
        collision.bounce=0.8;
        collision.userData = this;
        collision.maxVelocityY = 300;
		collision.maxVelocityX = 170;
        collision.dragX = 0.95;
        collisions.add(collision);
	}

	override function update(dt:Float) {
       
        super.update(dt);
        if(collision.isTouching(Sides.ALL)){
            collision.dragX=0.95;
            collision.accelerationY=GameGlobals.Gravity;
            canBePick=true;
        
            if(Math.abs(collision.velocityX)>50||Math.abs(collision.velocityY)>50){
                SM.playFx("woodHit");
            }
        }
        collision.update(dt);
        
	}
    public function pickedUp(layer:Layer) :Bool{
        if(!canBePick) return false;
        canBePick=false;
        picked=true;
        display.removeFromParent();
        layer.addChild(display);
        display.x=0;
        display.y=-5;
        collision.removeFromParent();
        return true;
    }
    public function shoot(x:Float,y:Float,dir:FastVector2) {
        reAddDelay=0.1;
        canBePick=false;
        picked=false;
        collision.x=x-dir.x*collision.width*0.5;
        collision.y=y;
        collision.velocityX=dir.x*500;
        collision.velocityY=dir.y*500;
        collision.dragX=1;
        display.removeFromParent();
        baseLayer.addChild(display);
        collisionGroup.add(collision);
        collision.accelerationY=0;
    }
	override function render() {
        super.render();
        if(picked)return;
		display.x =collision.x;
		display.y = collision.y;
    }
    override function destroy() {
        super.destroy();
        display.removeFromParent();
        collision.removeFromParent();
    }
}
