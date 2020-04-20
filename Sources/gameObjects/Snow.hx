package gameObjects;

import kha.math.FastVector2;
import com.framework.utils.Random;
import com.gEngine.display.Layer;
import com.helpers.MinMax;
import com.gEngine.display.Sprite;
import com.framework.utils.Entity;

class Snow extends Entity {
    
    var display:Sprite;
    var minmax:MinMax;
    var speed:Float=0;
    var time:Float=0;
    public function new(layer:Layer,x:Float,y:Float,width:Float,height:Float) {
       
        display=new Sprite("pixel");
        display.smooth=false;
        layer.addChild(display);
        minmax=MinMax.fromRec(x,y,width,height);
        display.x=Random.getRandomIn(x,x+width);
        display.y=Random.getRandomIn(y,y+height);
        super();
    }
    override function update(dt:Float) {
        time+=dt;
        speed=10;
        display.x+=Math.sin(time)*speed*dt;
        display.y+=speed*dt;
        if(!minmax.inside(display.x,display.y)){
            display.y=minmax.min.y+1;
            display.x=Random.getRandomIn(minmax.min.x,minmax.max.x);
        }
    }
}