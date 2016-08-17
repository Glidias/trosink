package troshx.tros;
import troshx.BodyChar;

/**
 * ...
 * @author Glidias
 */
@:expose
@:rtti
class Weapon
{
	public var atn:Int;	// slashing ATN
	public var atn2:Int; // thrusting ATN
	public var dtn:Int;	// melee DTN
	public var dntT:Int;  // melee DTN against thrusts of 4 cp or less
	public var dtn2:Int; // ranged DTN
	
	// ATN/Damage :  1 is for striking/swinging  or cutting(if damage3 is not undefined...used for bludgeoning) attacks,  2 is for spiking/thrusting attacks
	public var damage:Int;
	public var damage2:Int;
	public var damage3:Int;

	public var shield:Bool; // does this function as a shield for Block manuever?
	public var profeciencies:Array<String>;

	public var name:String;
	public var drawCutModifier:Int;
	public var attrBaseIndex:Int;
	public var twoHanded:Bool;
	public var rangedWeapon:Bool;
	public var cpPenalty:Float;
	public var movePenalty:Float;
	public var shieldLimit:Int;  // when up against a certain amount of CPs, then it can function as a Blockgin shield, otherwise, no Block manuever is available.
	public var blunt:Bool;  // flag to treat always as bludgeoning damage regardless, even for spiking/thrusting maoves...ie. a totally blunt weapon
	
	public var range:Int;
	
	public static inline var ATTR_BASE_NONE:Int = -1;
	public static inline var ATTR_BASE_STRENGTH:Int = 0;
	
	private static inline var HOOK_STRIKE:Int = 1;
	private static inline var HOOK_THRUST:Int = 2;
	public var hooking:Int;
	
	public function getDamageTo(body:BodyChar, manuever:Manuever, targetZone:Int, margin:Int, strength:Int):Int {
		var dmg:Int;
		if (damage3 != 0 && (blunt || manuever.damageType == Manuever.DAMAGE_TYPE_BLUDGEONING) ) {
			dmg = damage3;
		}
		else {
			dmg = Manuever.isThrustingMotion(targetZone, body) ? damage2 : damage;
		}
		
		dmg += margin;
		if (attrBaseIndex == ATTR_BASE_STRENGTH) dmg += strength;
		return dmg;
	}
	
	/**
	 * 
	 * @param	tieBiasToThrust	In case of draw of TN, prefer thrusts over striking?
	 * @return 	Positive TN value, depending on which TN is absolutely lower. 
	 */
	public function getHookingATN(tieBiasToThrust:Bool=false):Int {
		var strikeATN:Int = (hooking & HOOK_STRIKE) != 0  ? atn : 0;
		var thrustATN:Int = (hooking & HOOK_THRUST) != 0  ? atn2 : 0;
			return strikeATN != 0 && thrustATN != 0 ? 
				!tieBiasToThrust ? (thrustATN < strikeATN  ? -thrustATN : strikeATN) : (strikeATN < thrustATN  ? strikeATN : -thrustATN) : 
			(strikeATN == 0 ? -thrustATN : strikeATN);
	}
	
	
	/**
	 * 
	 * @param	tieBiasToThrust	In case of draw of TN, prefer thrusts over striking?
	 * @return 	TN in either negative or positive value, depending on which TN is absolutely lower. Negative values indicate thrusting motion instead.
	 */
	public function getHookingATNType(tieBiasToThrust:Bool=false):Int {
		var strikeATN:Int = (hooking & HOOK_STRIKE) != 0  ? atn : 0;
		var thrustATN:Int = (hooking & HOOK_THRUST) != 0  ? atn2 : 0;
		return strikeATN != 0 && thrustATN != 0 ? 
				!tieBiasToThrust ? (thrustATN < strikeATN  ? -thrustATN : strikeATN) : (strikeATN < thrustATN  ? strikeATN : -thrustATN) : 
			(strikeATN == 0 ? -thrustATN : strikeATN);
	}
	
	

	public function new(name:String, profGroups:Array<String>) {
		this.name = name;
		this.profeciencies = profGroups;
		// ManueverSheet.getMaskWithHashIndexer(profGroups, ProfeciencySheet.listHashIndexer);
		attrBaseIndex = ATTR_BASE_STRENGTH;
		drawCutModifier = 0;
		damage = 0;
		damage2 = 0;
		damage3 = 0;
		atn = 0;
		atn2 = 0;
		dtn = 0;
		dtn2 = 0;
		twoHanded = false;
		rangedWeapon = false;
		shield = false;
		shieldLimit = 0;
		cpPenalty = 0;
		movePenalty = 0;
		blunt = false;
		hooking = 0;
	}
	
	public static function createDyn(name:String, profGroups:Array<String>, properties:Dynamic):Weapon {
		var weap:Weapon = new Weapon(name, profGroups);
		for (p in Reflect.fields(properties)) {
			Reflect.setField(weap, p, Reflect.field(properties, p)); // [p];
		}
		return weap;
	}
	
	

	
}