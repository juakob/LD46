package gameObjects;

import com.collision.platformer.CollisionGroup;
import com.gEngine.display.Layer;


class GameGlobals {
    public static inline var Gravity:Float=1000;
    public static var simulationLayer:Layer;

   public static function clear() {
      simulationLayer=null;
   }
}