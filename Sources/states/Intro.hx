package states;

import com.gEngine.display.Sprite;
import kha.input.KeyCode;
import com.framework.utils.Input;
import com.loading.basicResources.ImageLoader;
import com.loading.Resources;
import com.framework.utils.State;

class Intro extends State {
    var intro:Sprite;
    override function load(resources:Resources) {
        resources.add(new ImageLoader("intro"));
      //  resources.add(new FontLoader("mainfont"));
    }
    public function new() {
        super();
    }
    override function init() {
        intro=new Sprite("intro");
        intro.smooth=false;
        intro.scaleX=intro.scaleY=4;
       stage.addChild(intro);
    }
    override function update(dt:Float) {
        super.update(dt);
        if(Input.i.isKeyCodePressed(KeyCode.Space)||Input.i.isMousePressed()){
            changeState(new Test("room1")); 	
        }
    }
}