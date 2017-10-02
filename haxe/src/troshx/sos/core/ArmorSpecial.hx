package troshx.sos.core;
import troshx.sos.core.ArmorSpecial.HitModifier;
import troshx.util.LibUtil;

/**
 * ArmorSpecial exists as a BodyChar specific entity, defaults to Humanoid singleton if not specified. 
 * @author Glidias
 */
class ArmorSpecial 
{
	public static inline var MOVABLE:Int = (1 << 0);
	public static inline var HARD:Int = (1 << 1);
	public static inline var MAIL:Int = (1 << 2);
	public static inline var TEXTILE:Int = (1 << 3);
	public static inline var BULLETPROOF:Int = (1 << 4);
	
	
	@:flag public var restrictsBreathing:Int = 0;
	
	public var layer:Int = 0;
	public var layerCoverage:Int = 0;
	
	public var wornWith:WornWith = null;
	
	public var hitModifier:HitModifier= null;  // Currently, it seems 100% of the armor piece examples provides only a single hit modifier entry
	//public var modifiers:Array<HitModifiers> = null; // So, can forego using array
	
	// is this armor restricted to another body type or is default?
	// Changing this property will require imperative update/re-mapping of any modifiers/layers under this class
	// and possibly udner the parent Armor class as well if IntIntHash is used for coverage
	public var otherBodyType:BodyChar = null; 
	
	public function new() 
	{
		
	}
	
	public function addTagsToStrArr(arr:Array<String>, curArmor:Armor) 
	{
		var instance:ArmorSpecial = this;
		
		var bodyChar:BodyChar = otherBodyType != null ? otherBodyType : BodyChar.getInstance();
		if (otherBodyType != null) {
			arr.push("For Body Type: "+bodyChar.name);
		}
		
		Item.pushVarLabelsToArr(true, "troshx.sos.core.ArmorSpecial", ":flag");
		
		/*
		if (layerings != null) {
			for (i in 0...layerings.length) {
				var layering = layerings[i];
				//if (layering.value > 0) {
				layering.addTagsToStrArr(arr, bodyChar);
				//}
			}		
		}
		*/
		if (layer > 0) {
			if (layerCoverage != 0) {
				var myArr:Array<String> = [];
				bodyChar.pushHitLocationNamesToStrArrByMask(myArr, layerCoverage);	
				arr.push( 'Layer'+(myArr.length > 0 ? "s" : "")+' ${layer} (${myArr.join(", ")})' );
			}
			else {
				arr.push('Layer ${layer}');
			}
		}
		
		if (hitModifier != null) {
			
			hitModifier.addTagsToStrArr(arr, bodyChar);
			
		}
		
		if (wornWith != null) {
			wornWith.addTagsToStrArr(arr, curArmor);
		}

	}
	

}



class HitModifier {	// Location/target-hit-zone specific modifiers
	
	public var locationMask:Int = 0;
	public var targetZoneMask:Int = 0;
	public var multiplyAV:Float = 1; // provides a fraction of given AV by multiplier fractional
	public var addAV:Int = 0;  // provides additional/reduced AV
	
	public function new() {
		
	}
	
	public function addTagsToStrArr(arr:Array<String>, bodyChar:BodyChar)  {
		
		if ( (targetZoneMask == 0 && locationMask == 0) || (multiplyAV == 1 && addAV == 0) ) return;
		var swingAll = bodyChar.isSwingingAll(targetZoneMask);
		var thrustAll = bodyChar.isThrustingAll(targetZoneMask);
		if (locationMask == 0 && swingAll && thrustAll) return;
		var bothHave:Bool = addAV != 0 && multiplyAV != 1;
	
		var damageStr:String = 	multiplyAV == 0 && addAV == 0 ? "No AV" : (addAV < 0 ? "Reduced " : "") + (!bothHave ? multiplyAV != 1 ? (multiplyAV == 0.5 ? "Provides Half AV" : multiplyAV + "x AV") : (addAV > 0 ? "+" : "") + addAV  + " AV": multiplyAV != 0 ? ((addAV > 0 ? "+" : "") + addAV + " AV " + "over " + (multiplyAV == 0.5 ? "Half AV" : multiplyAV + "x AV") ) : addAV > 0 ? "Only " + addAV + " AV" : "+" + ( -addAV) + " damage"   );
		//bodyChar.nameLocation();
		arr.push( 
			damageStr + (targetZoneMask != 0 && !(swingAll && thrustAll) ?  " vs " +bodyChar.describeTargetZones(targetZoneMask) : "") + (locationMask != 0 ?  " on "+bodyChar.getLabelsHitLocationMask(locationMask).join(" ,") :  "")   
		);
		
	}
}

class WornWith {
	public var name:String = "";
	public var layer:Int = 0;
	
	public function new() {
		
	}
	
	public function addTagsToStrArr(arr:Array<String>, curArmor:Armor) 
	{
		if (name == "") return;
		if (layer == USE_AV_SELF || layer == USE_AV_OTHER) {
			arr.push( "When worn with "+name+" use "+(layer == USE_AV_SELF ? curArmor.name : name ) + " AV value instead" );
		}
		else {
			arr.push( "Can be worn with "+name + " for Layer "+layer );
		}
	}
	
	public static inline var USE_AV_SELF:Int = 0;
	public static inline var USE_AV_OTHER:Int = -1;
}
