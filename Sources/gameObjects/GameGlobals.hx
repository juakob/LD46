package gameObjects;

import com.collision.platformer.CollisionGroup;
import com.gEngine.display.Layer;


class GameGlobals {
    public static inline var Gravity:Float=600;
    public static var simulationLayer:Layer;
    public static var currentLevel:Int=1;
    public static var totalLevels:Int=11;

   public static function clear() {
      simulationLayer=null;
   }
}