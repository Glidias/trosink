package troshx.sos.vue.uifields;
import haxevx.vuex.core.VComponent;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class UI 
{
	static var COMPONENTS:Dynamic;
	public static function getComponents():Dynamic {
		return COMPONENTS != null ? COMPONENTS : (COMPONENTS = getNewSetOfComponents());
	}
	
	public static function getNewSetOfComponents(excludeArray:Bool=false):Dynamic<VComponent<Dynamic,Dynamic>> {
		var dyn:Dynamic = {};
		if (!excludeArray) LibUtil.setField(dyn, ArrayOf.NAME, new ArrayOf()); 
		LibUtil.setField(dyn, Bitmask.NAME, new Bitmask()); 
		LibUtil.setField(dyn, FieldNumber.NAME, new FieldNumber()); 
		LibUtil.setField(dyn, FieldInt.NAME, new FieldInt()); 
		LibUtil.setField(dyn, FieldString.NAME, new FieldString()); 
		LibUtil.setField(dyn, FieldTextArea.NAME, new FieldTextArea()); 
		LibUtil.setField(dyn, SingleSelection.NAME, new SingleSelection());
		LibUtil.setField(dyn, HitLocationSelector.NAME, new HitLocationSelector());
		
		return dyn;
	}
	
	
	
}