package troshx.sos.vue;
import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.Event;

/**
 * ...
 * @author Glidias
 */
class GlobalCanvas2D
{
	public static var CANVAS(default, null):CanvasElement;
	static var CONTEXT:CanvasRenderingContext2D;
	
	
	
	public static inline function getContext():CanvasRenderingContext2D {
		return CONTEXT;
	}
	public static function __setupContext(canvas:CanvasElement, context:CanvasRenderingContext2D, fullScreen:Bool = false):Void {
		if (CANVAS != null) {
			trace("GlobalCanvas2D:: Global canvas already set! Cannot set again");
			return;
		}
		CANVAS = canvas;
		CONTEXT = context;
		if (fullScreen) {
			Browser.window.addEventListener("resize", canvasResizeHandler);
			canvasResizeHandler();
		}
	}
	
	static function canvasResizeHandler(e:Event=null):Void {
		var wd = Browser.window;
		var c = CANVAS;
		c.width = wd.innerWidth;
		c.height = wd.innerHeight;

	}
	
}