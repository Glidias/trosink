package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;

/**
 * ...
 * @author Glidias
 */
class UIMixin extends VComponent<NoneT, NoneT>
{

	function new() 
	{
		super();
	}
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return UI.getComponents();
	}
	
	static var INSTANCE:UIMixin;
	public static function getInstance():UIMixin {
		return INSTANCE != null ? INSTANCE : (INSTANCE = new UIMixin());
	}
	
}