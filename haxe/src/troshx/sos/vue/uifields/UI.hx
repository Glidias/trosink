package troshx.sos.vue.uifields;
import haxevx.vuex.core.VComponent;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class UI 
{
	static var COMPONENTS:Dynamic<VComponent<Dynamic,Dynamic>>;
	public static function getComponents():Dynamic<VComponent<Dynamic,Dynamic>> {
		return COMPONENTS != null ? COMPONENTS : (COMPONENTS = getNewSetOfComponents());
	}
	
	public static function getNewSetOfComponents(excludeArray:Bool=false):Dynamic<VComponent<Dynamic,Dynamic>> {
		var dyn:Dynamic = {};
		if (!excludeArray) {
			LibUtil.setField(dyn, ArrayOf.NAME, new ArrayOf()); 
			LibUtil.setField(dyn, ArrayOfBits.NAME, new ArrayOfBits()); 
		}
		LibUtil.setField(dyn, Bitmask.NAME, new Bitmask()); 
		LibUtil.setField(dyn, FieldNumber.NAME, new FieldNumber()); 
		LibUtil.setField(dyn, FieldInt.NAME, new FieldInt()); 
		LibUtil.setField(dyn, FieldString.NAME, new FieldString()); 
		LibUtil.setField(dyn, FieldTextArea.NAME, new FieldTextArea()); 
		LibUtil.setField(dyn, SingleSelection.NAME, new SingleSelection());
		LibUtil.setField(dyn, SingleBitSelection.NAME, new SingleBitSelection());
		
		LibUtil.setField(dyn, MoneyField.NAME, new MoneyField());
		LibUtil.setField(dyn, HitLocationSelector.NAME, new HitLocationSelector());
		LibUtil.setField(dyn, HitLocationMultiSelector.NAME, new HitLocationMultiSelector());
		LibUtil.setField(dyn, WealthAssetField.NAME, new WealthAssetField());
		return dyn;
	}
	
	
	static var TYPES:Dynamic<String>;
	public static function getTypeMapToComponentNames():Dynamic<String> {
		return TYPES != null ? TYPES : (TYPES = getNewTypeMapToComponentNames());
	}
	
	public static function getNewTypeMapToComponentNames():Dynamic<String> {
		return {
			"Array": ArrayOf.NAME,
			"ArrayOfBits": ArrayOfBits.NAME,
			"Bitmask": Bitmask.NAME,
			"Float":FieldNumber.NAME,
			"Int":FieldInt.NAME,
			"String":FieldString.NAME,
			"textarea":FieldTextArea.NAME,
			"SingleSelection":SingleSelection.NAME,
			"SingleBitSelection":SingleBitSelection.NAME,
			
			"HitLocationSelector":HitLocationSelector.NAME,
			"HitLocationMultiSelector":HitLocationMultiSelector.NAME,
			"Money":MoneyField.NAME,
			"WealthAssetAssign":WealthAssetField.NAME
		};
	}
	
	
	
}