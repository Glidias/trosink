package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.core.Arrow;

/**
 * ...
 * @author Glidias
 */
class WAmmoSpawner extends VComponent<NoneT, WAmmoSpawnerProps>
{
	
	public static inline var NAME:String = "w-ammo-spawner";

	public function new() 
	{
		super();
		Arrow;
	}
	
}

typedef WAmmoSpawnerProps = {
	@:prop({required:false, "default":0}) @:optional var mask:Int;
}