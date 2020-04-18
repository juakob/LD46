package;


import states.BasicLoader;
import kha.WindowMode;
import com.framework.Simulation;
import kha.System;
import kha.System.SystemOptions;
import kha.FramebufferOptions;
import kha.WindowOptions;
import states.Test;


class Main {
    public static function main() {
		#if hotml new hotml.Client(); #end
		
			var windowsOptions=new WindowOptions("LD46",0,0,1280,720,null,true,WindowFeatures.FeatureResizable,WindowMode.Windowed);
		var frameBufferOptions=new FramebufferOptions();
		System.start(new SystemOptions("LD46",1280,720,windowsOptions,frameBufferOptions), function (w) {
			new Simulation(Test,1280,720);
        });
    }
}
