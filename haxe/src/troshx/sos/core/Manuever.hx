package troshx.sos.core;
import troshx.components.FightState;
import troshx.components.FightState.ManueverDeclare;
import troshx.core.IManuever;
import troshx.core.IUid;
import troshx.sos.events.SOSEvent;
import troshx.sos.manuevers.StealInitiative;
import troshx.sos.sheets.CharSheet;
import troshx.util.AbsStringMap;
import troshx.util.UidStringMapCreator;

/**
 * ...
 * @author Glidias
 */
class Manuever implements IManuever implements IUid
{
	public var id:String;
	public var name:String;
	
	public var shooting:Bool = false;
	public var advanced:Bool = false;
	public var instant:Bool = false;
	
	public var types:Int = 0;
	public static inline var TYPE_DEFENSIVE:Int = 1;
	public static inline var TYPE_OFFENSIVE:Int = 2;
	public static inline var TYPE_BOTH:Int = (TYPE_DEFENSIVE | TYPE_OFFENSIVE);
	public static inline var TYPE_MOVEMENT:Int = 4;
	public static inline var TYPE_TRANSFORMATION:Int = 8;
	public static inline var TYPE_INITIATIVE:Int = 16;
	public static inline var TYPE_PASSING:Int = 32;
	@:col public function _types(val:Int):Manuever {
		types = val;
		return this;
	}
	
	public var attackTypes:Int = 0;
	public static inline var ATTACK_TYPE_SWING:Int = 1;
	public static inline var ATTACK_TYPE_THRUST:Int = 2;
	public static inline var ATTACK_TYPE_BOTH:Int = (ATTACK_TYPE_SWING | ATTACK_TYPE_THRUST);
	public static inline var ATTACK_TYPE_BUTT:Int = 4;
	
	@:col public function _attackTypes(val:Int):Manuever {
		attackTypes = val;
		return this;
	}
	
	public var requisites:Int = 0;
	public static inline var REQ_WEAPON:Int = 1;
	public static inline var REQ_SHIELD:Int = 2;
	public static inline var REQ_UNARMED:Int = 4;
	public static inline var REQ_STUFF:Int = 8;
	@:col public function _requisite(val:Int):Manuever {
		requisites = val;
		return this;
	}
	public function getAdditionalRequire(charSheet:CharSheet, fightState:Int):Bool {
		return true;
	}
	
	public var superiorManuever:Manuever;
	public function _superiorManuever(val:Manuever):Manuever {
		superiorManuever = val;
		return this;
	}
	
	public function clone():Manuever {
		var manuever = Type.createEmptyInstance(Type.getClass(this));
		clonePropertiesFrom(manuever);
		return manuever;
	}
	
	public function clonePropertiesFrom(manuever:Manuever) {
		
		manuever.shooting = shooting;
		manuever.advanced = advanced;
		manuever.instant = instant;
		manuever.cost = cost;
		
		manuever.types = types;
		manuever.attackTypes = attackTypes;
		
		manuever.tags = tags;
		manuever.usingHands = usingHands;
	}
	
	public var tags:Int = 0;
	public static inline var TAG_CROSS_FIGHTING:Int = (1 << 0);
	public static inline var TAG_GRAPPLE:Int = (1 << 1);
	public static inline var TAG_CLINCHING:Int = (1 << 2);
	public static inline var TAG_PUSH:Int = (1 << 3);
	public static inline var TAG_GRAB:Int = (1 << 4);
	
	public static inline var TAG_BASH:Int = (1 << 5);
	public static inline var TAG_PARRY:Int = (1 << 6);
	public static inline var TAG_VOID:Int = (1 << 7);
	public static inline var TAG_BLOCK:Int = (1 << 8);
	@:col public function _tags(val:Int):Manuever {
		tags = val;
		return this;
	}
	
	public var usingHands:Int = 0;
	public static inline var HANDS_NONE:Int = 0;
	public static inline var HANDS_MASTER:Int = 1; 
	public static inline var HANDS_SECONDARY:Int = 2;
	public static inline var HANDS_BOTH:Int = 3;  // a union mask of 1|2
	public function _usingHands(val:Int):Manuever {
		usingHands = val;
		return this;
	}
	
	public var tn:Int = 0;
	@:col public function _tn(val:Int):Manuever {
		tn = val;
		return this;
	}
	
	public var cost:Int = 0;
	public var costFuncInputs:Int = 0;
	@:col public function _costs(cost:Int, costFuncInputs:Int=0):Manuever {
		this.cost = cost;
		this.costFuncInputs = costFuncInputs;
		return this;
	}
	
	public function handleEvent(sheet:CharSheet, fightState:FightState, declare:ManueverDeclare, event:SOSEvent):Bool {
		return false;
	}
	
	public function getCost(sheet:CharSheet, fightState:FightState, inputs:Array<Int>):Int {
		return cost;
	}
	
	public function resolve(sheet:CharSheet, state:FightState, declare:ManueverDeclare):Void {
		//var manuevers = getMap();
	}

	public function new(id:String, name:String) 
	{
		this.id = id;
		this.name = name;
	}
	
	
	/* INTERFACE troshx.core.IUid */
	
	public var uid(get, never):String;
	
	inline function get_uid():String 
	{
		return this.id;
	}
	
	
	// Singleton references
	
	static var MAP:AbsStringMap<Manuever>;
	public static function getMap():AbsStringMap<Manuever> {
		return MAP != null ? MAP : (MAP = getNewMap());
	}
	public static function getNewMap():AbsStringMap<Manuever> {
		return  UidStringMapCreator.createStrMapFromArray(getNewArray());
	}
	
	static var ARRAY:Array<Manuever>;
	public static function getArray():Array<Manuever> {
		return ARRAY != null ? ARRAY : (ARRAY = getNewArray());
	}
	
	// hardcode this or excel???
	public static function getNewArray():Array<Manuever> {
		return [
			new Manuever("swing", "Swing")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_SWING),
			
			new Manuever("thrust", "Thrust")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_THRUST),
			
			
			new Manuever("parry", "Parry")._types(TYPE_DEFENSIVE)._requisite(REQ_WEAPON)._tags(TAG_PARRY),
			
			new Manuever("void", "Void")._types(TYPE_DEFENSIVE)._tags(TAG_VOID)._tn(8),
				new Manuever("mobileVoid", "Mobile Void")._types(TYPE_DEFENSIVE)._tags(TAG_VOID)._tn(8),
				new Manuever("flee", "Flee")._types(TYPE_DEFENSIVE)._tags(TAG_VOID)._tn(5),

			new Manuever("block", "Block")._types(TYPE_OFFENSIVE)._requisite(REQ_SHIELD)._tags(TAG_BLOCK),
			
			new StealInitiative(),
			
			
		];
	}
	
}