package states;

import com.soundLib.SoundManager.SM;
import com.loading.basicResources.SoundLoader;
import gameObjects.FirePlace;
import com.collision.platformer.ICollider;
import kha.audio1.AudioChannel;
import com.framework.utils.XboxJoystick;
import com.framework.utils.VirtualGamepad;
import com.loading.basicResources.ImageLoader;
import format.tmx.Data.TmxObject;
import com.gEngine.display.TextDisplay;
import com.g3d.Object3d;
import kha.input.KeyCode;
import com.framework.utils.Input;
import com.gEngine.display.StaticLayer;
import com.collision.platformer.CollisionGroup;
import com.collision.platformer.CollisionEngine;
import gameObjects.Player;
import com.loading.basicResources.TilesheetLoader;
import com.gEngine.display.Layer;
import com.loading.basicResources.DataLoader;
import com.collision.platformer.Tilemap;
import com.loading.basicResources.JoinAtlas;
import com.loading.Resources;
import com.framework.utils.State;
import gameObjects.GameGlobals;
import gameObjects.WoodLog;

class Test extends State {
	var worldMap:Tilemap;
	var player:Player;
	var enemiesCollisions:CollisionGroup;
	var rainCollisions:CollisionGroup;
	var doors:CollisionGroup;
	var bullets:CollisionGroup;
	var hudLayer:StaticLayer;
	var pumpkinIcon:Object3d;
	var pumpkinKillText:TextDisplay;
	var pumpkinKill:Int = 0;
	var simulationLayer:Layer;
	var room:String;
	var fromRoom:String;
	var touchJoystick:VirtualGamepad;
	var rainSound:AudioChannel;
	var pickables:CollisionGroup;

	var wood:WoodLog;

	public function new(room:String="", fromRoom:String = null) {
		super();
		this.room = "testRoom";
		this.fromRoom = fromRoom;
	}

	override function load(resources:Resources) {
		resources.add(new DataLoader("testRoom_tmx"));
		var atlas = new JoinAtlas(2048, 2048);

		atlas.add(new TilesheetLoader("tiles", 6, 5, 0));
		atlas.add(new ImageLoader("player"));
		atlas.add(new ImageLoader("wood"));
		atlas.add(new ImageLoader("direction"));
		atlas.add(new ImageLoader("firePlace"));
		resources.add(atlas);
		resources.add(new SoundLoader("fight"));
	}

	override function init() {
		SM.playMusic("fight");
		pickables=new CollisionGroup();
		stageColor(0.5, .5, 0.5);
		simulationLayer = new Layer();
		var backgroundLayer = new Layer();
		simulationLayer.addChild(backgroundLayer);
		GameGlobals.simulationLayer = simulationLayer;
		stage.addChild(simulationLayer);

		hudLayer = new StaticLayer();
		stage.addChild(hudLayer);

		enemiesCollisions = new CollisionGroup();
		doors = new CollisionGroup();
		rainCollisions = new CollisionGroup();

		worldMap = new Tilemap("testRoom_tmx", "tiles", 1);
		worldMap.init(function(layerTilemap, tileLayer) {
			if (!tileLayer.properties.exists("noCollision")) {
				layerTilemap.createCollisions(tileLayer);
			}
			simulationLayer.addChild(layerTilemap.createDisplay(tileLayer));
		}, parseMapObjects);
		stage.defaultCamera().limits(0, 0, worldMap.widthIntTiles * 6 , worldMap.heightInTiles * 5);
		stage.defaultCamera().scale=5;
		//for (i in 0...totalTiles) {
		//	mayonnaiseMap.setTile2(i, 1);
		//}
		
		

		

		createTouchJoystick();
	}

	function createTouchJoystick() {
		var border:Int = 20;

		touchJoystick = new VirtualGamepad();
		touchJoystick.addKeyButton(XboxJoystick.LEFT_DPAD, KeyCode.Left);
		touchJoystick.addKeyButton(XboxJoystick.RIGHT_DPAD, KeyCode.Right);
		touchJoystick.addKeyButton(XboxJoystick.UP_DPAD, KeyCode.Up);
		touchJoystick.addKeyButton(XboxJoystick.DOWN_DPAD, KeyCode.Down);
		touchJoystick.addKeyButton(XboxJoystick.A, KeyCode.Space);
		touchJoystick.addKeyButton(XboxJoystick.X, KeyCode.X);
		touchJoystick.notify(player.onAxisChange, player.onButtonChange);

		var gamepad = Input.i.getGamepad(0);
		gamepad.notify(player.onAxisChange, player.onButtonChange);
	}

	function parseMapObjects(layerTilemap:Tilemap, object:TmxObject) {
		if(object.type=="firePlace"){
			var firePlace=new FirePlace(simulationLayer,doors);
			firePlace.collision.x = object.x;
			firePlace.collision.y = object.y-object.height;
			addChild(firePlace);
		}
		if(object.type=="playerStart"){
			player = new Player(simulationLayer);
			player.collision.x = object.x;
			player.collision.y = object.y;
			addChild(player);
		}
		if(object.type=="woodStart"){
			wood=new WoodLog(simulationLayer,pickables);
			wood.collision.x=object.x;
			wood.collision.y=object.y;
			addChild(wood);
		}
	}
	/*function parseMapObjects(layerTilemap:Tilemap,object:TmxObject){
		if(object.type=="enemy"){
			var count=Std.parseInt(object.properties.get("enemyCount"));
			for(i in 0...count){
				var enemy=new gameObjects.Enemy(object.x*4+Math.random()*object.width*4,object.y*4+Math.random()*object.height*4);
				addChild(enemy);
				simulationLayer.addChild(enemy.display);
				enemiesCollisions.add(enemy.collision);
			}
		}else
		if(object.type=="player"&&ivanka==null){
			ivanka=new Player(object.x*4,object.y*4);
			simulationLayer.addChild(ivanka.display);
			addChild(ivanka);
		}else
		if(object.type=="door"){
			var door=new CollisionBox();
			door.x=object.x*4;
			door.y=object.y*4;
			door.width=object.width*4;
			door.height=object.height*4;
			door.userData=object.properties.get("goTo");
			doors.add(door);
			if(door.userData==fromRoom){
				if(ivanka==null){
					ivanka=new Player(object.x*4,object.y*4);
					simulationLayer.addChild(ivanka.display);
					addChild(ivanka);
				}else{
					ivanka.collision.x=object.x*4;
					ivanka.collision.y=object.y*4;
				}
			}
		}else
		if(object.type=="rain"){
			var drops:Int=Std.int(object.width*object.height*4/1000);

			for(i in 0...drops){
				var drop=new fx.Drop(object.y*4,(object.y+object.height)*4,object.x*4,(object.x+object.width)*4,800+Math.random()*200);
				simulationLayer.addChild(drop.display);
				addChild(drop);
			}
		}else
		if(object.type=="sound"){
			if(rainSound==null){rainSound = SM.playFx("rain",true);}
			var rainBox=new CollisionBox();
			rainBox.x=object.x*4;
			rainBox.y=object.y*4;
			rainBox.width=object.width*4;
			rainBox.height=object.height*4;
			rainCollisions.add(rainBox);
		}else
		if(object.type=="asset"){
			 var display=new BasicSprite(object.properties.get("asset"));
			 display.scaleX=(object.width/display.width())*4;
			 display.scaleY=(object.height/display.height())*4;
			 display.offsetY=-display.height();// origin at the bottom?
			 display.x=object.x*4;
			 display.y=object.y*4;
			 display.rotation=object.rotation*Math.PI/180;
			 simulationLayer.addChild(display);
			 if(object.properties.exists("blend")){
				if(object.properties.get("blend")=="add"){
					display.blend=com.gEngine.display.BlendMode.Add;
				}
			 }
			 if(object.properties.exists("multiply")){
				 var color:kha.Color=kha.Color.fromString(object.properties.get("multiply"));
				 display.colorMultiplication(color.R,color.G,color.B,color.A);
			 }
			 display.smooth=!(object.properties.exists("smooth")&&object.properties.get("smooth")=="false");
		}
	}*/

	override function update(dt:Float) {
		super.update(dt);

		CollisionEngine.collide(player.collision, worldMap.collision);
		for(pickable in pickables.colliders){
			CollisionEngine.bulletCollide(cast pickable, worldMap.collision,10);
		}
		
		CollisionEngine.overlap(pickables, player.collision,woodVsPlayer);
		CollisionEngine.overlap(pickables, doors,woodVsFirePlace);

		stage.defaultCamera().setTarget(player.display.x, player.display.y);
		#if DEBUGDRAW
		if(Input.i.isKeyCodeReleased(KeyCode.F9)){
			debugDraw = !debugDraw;
		}
		#end
	}

	public function woodVsPlayer(woodC:ICollider,playerC:ICollider) {
		var wood:WoodLog=cast woodC.userData;
		var player:Player=cast playerC.userData;
		player.pickUp(wood);
		
	}
	public function woodVsFirePlace(woodC:ICollider,playerC:ICollider) {
		changeState(new Test());
	}

	override function destroy() {
		this.touchJoystick.destroy();
		super.destroy();

	}

	#if DEBUGDRAW
	var debugDraw:Bool=true;
	override function draw(framebuffer:kha.Canvas) {
		super.draw(framebuffer);
		
		if(debugDraw){
			var camera=stage.defaultCamera();
			CollisionEngine.renderDebug(framebuffer,camera);
		}
	}
	#end
}
