package troshx.sos.core;
import troshx.components.Bout;
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
	
	public var isSuperior(default, null):Bool = false;
	
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
	public static inline var ATTACK_TYPE_SHOOTING:Int = 8;
	
	@:col public function _attackTypes(val:Int):Manuever {
		attackTypes = val;
		return this;
	}
	
	public var requisites:Int = 0;
	public var reqStuffs:Array<String> = null;	// used for REQ_STUFF only
	public static inline var REQ_WEAPON:Int = 1;
	public static inline var REQ_SHIELD:Int = 2;
	public static inline var REQ_UNARMED:Int = 4;
	public static inline var REQ_STUFF:Int = 8;
	@:col public function _requisite(val:Int, reqStuffs:Array<String>=null):Manuever {
		requisites = val;
		this.reqStuffs = reqStuffs;
		return this;
	}
	public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>):Bool {
		return true;
	}
	
	
	public static inline var TARGET_ZONE_AUTO:Int = 0;  // determined from attack type
	public static inline var TARGET_ZONE_WEAPON:Int = 1;
	public static inline var TARGET_ZONE_SHIELD:Int = 2;
	public static inline var TARGET_ZONE_OPPONENT:Int = 3;
	
	public static inline function specificTargetZoneModeMask(val:Int):Int {
		return -val;
	}
	
	public var targetZoneMode:Int = TARGET_ZONE_AUTO;
	@:col public function _targetZoneMode(val:Int):Manuever {
		targetZoneMode = val;
		return this;
	}
	
	public var superiorManuever:Manuever;
	public function _superior(val:Manuever=null):Manuever {
		var manuever = val != null ? val : clone();
		manuever.isSuperior = true;
		return this;
	}
	public function _superiorInit(func:Manuever->Void):Manuever {
		var manuever = clone();
		manuever.isSuperior = true;
		func(manuever);
		return this;
	}
	
	public function clone():Manuever {
		var manuever = Type.createEmptyInstance(Type.getClass(this));
		clonePropertiesFrom(manuever);
		return manuever;
	}
	
	public function clonePropertiesFrom(manuever:Manuever) {
		manuever.name = name;
		
		manuever.cost = cost;
		manuever.costFuncInputs = costFuncInputs;
		
		manuever.types = types;
		manuever.attackTypes = attackTypes;
		manuever.requisites = requisites;
		manuever.reqStuffs = reqStuffs;
		
		manuever.targetZoneMode = targetZoneMode;
		
		manuever.tags = tags;
		manuever.usingHands = usingHands;
		
		manuever.tn = tn;
		manuever.bs = bs;
		//manuever.tnMod = tnMod;
		
		manuever.reach = reach;
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
	
	public static inline var TAG_ADVANCED:Int = (1 << 9);
	public static inline var TAG_INSTANT:Int = (1 << 10);
	
	
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
	//public var tnMod:Bool = false;
	@:col public function _tn(val:Int):Manuever { //, mod:Bool=false
		tn = val;
		//tnMod = mod;
		return this;
	}
	
	public var bs:Int = 0;
	@:col public function _bs(val:Int):Manuever {
		bs = val;
		return this;
	}
	
	public var cost:Int = 0;
	public var costFuncInputs:Int = 0;
	public var costVaries:Bool = false;
	@:col public function _costs(cost:Int, costFuncInputs:Int=0, costVaries:Bool=false):Manuever {
		this.cost = cost;
		this.costFuncInputs = costFuncInputs;
		this.costVaries = costVaries;
		return this;
	}
	
	public var reach:Int = 0;
	@:col public function _reach(val:Int):Manuever {
		this.reach = 0;
		return this;
	}
	public inline function hasOwnReach():Bool {
		return this.reach > 0;
	}
	public inline function isRanged():Bool {
		return this.reach < 0;
	}
	public function _ranged():Manuever {
		this.reach = -1;
		return this;
	}
	
	public function handleEvent(sheet:CharSheet, fightState:FightState, declare:ManueverDeclare, event:SOSEvent):Bool {
		return false;
	}
	
	public function getCost(bout:Bout<CharSheet>, node:FightNode<CharSheet>, inputs:Array<Int>):Int {
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
		
			// Swings and thrusts
			new Manuever("swing", "Swing")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_SWING),
				new Manuever("drawCut", "Draw Cut")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_SWING),
				new Manuever("cleavingBlow", "Cleaving Blow")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_SWING)._tags(TAG_CROSS_FIGHTING),	// defered instant on resolve after
				
			new Manuever("thrust", "Thrust")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_THRUST),
				/**/ new Manuever("pushCut", "Push Cut")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_THRUST)._costs(1)._superior(),
				new Manuever("jointThrust", "Joint Thrust")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_THRUST)._costs(0,0,true),
			
			// Hooks and feints shared by both swing and thrusts
			new Manuever("hook", "Hook")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_BOTH)._targetZoneMode(TARGET_ZONE_SHIELD|TARGET_ZONE_OPPONENT)._superior(),
			new Manuever("feint", "Feint")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_BOTH)._costs(2)._superior(), // defered instant before resolution
			
			// Aim at weapon/shield
			new Manuever("disarm", "break")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_SWING)._targetZoneMode(TARGET_ZONE_WEAPON)._superior(),
			new Manuever("beat", "Beat")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_SWING)._targetZoneMode(TARGET_ZONE_WEAPON)._superior(),
			new Manuever("break", "Break")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_SWING)._targetZoneMode(TARGET_ZONE_WEAPON)._superior(),
			new Manuever("hew", "Hew")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_SWING)._targetZoneMode(TARGET_ZONE_SHIELD)._superior(),
			
			// Parries
			new Manuever("parry", "Parry")._types(TYPE_DEFENSIVE)._requisite(REQ_WEAPON)._tags(TAG_PARRY),
				new Manuever("riposte", "Riposte")._types(TYPE_DEFENSIVE)._requisite(REQ_WEAPON)._tags(TAG_PARRY | TAG_ADVANCED)._costs(2)._superior(),
				new Manuever("armParryUnarmed", "Armed Parry (Unarmed)")._types(TYPE_DEFENSIVE)._requisite(REQ_UNARMED)._tags(TAG_PARRY),
				new Manuever("disarmUnarmed", "Disarmed (Unarmed)")._types(TYPE_DEFENSIVE)._requisite(REQ_UNARMED)._tags(TAG_PARRY)._costs(1)._reach(Weapon.REACH_HA)._tn(8)._superiorInit(function(m){m._tn(7); }),
			
			// Voids
			new Manuever("void", "Void")._types(TYPE_DEFENSIVE)._tags(TAG_VOID)._tn(8)._bs(2),
				new Manuever("hastyVoid", "Hasty Void")._types(TYPE_DEFENSIVE)._tags(TAG_VOID)._tn(7)._bs(2),
				new Manuever("mobileVoid", "Mobile Void")._types(TYPE_DEFENSIVE)._tags(TAG_VOID)._tn(8)._bs(1),
				/**/ new Manuever("flee", "Flee")._types(TYPE_DEFENSIVE)._tags(TAG_VOID)._tn(5),
				
			// Blocks
			new Manuever("block", "Block")._types(TYPE_DEFENSIVE)._requisite(REQ_SHIELD)._tags(TAG_BLOCK),
				new Manuever("shieldBind", "Shield Bind")._types(TYPE_DEFENSIVE)._requisite(REQ_SHIELD)._tags(TAG_BLOCK | TAG_ADVANCED)._superior(),
				/**/ new Manuever("totalBlock", "Total Block")._types(TYPE_DEFENSIVE)._requisite(REQ_SHIELD)._tags(TAG_BLOCK),  
			
			// Shield/other alts
			//Swipe Up Shield for sub menu  and tap on Shield Feint as an option. Will revert back to weapon being selected.
			// alt-feints
			new Manuever("shieldFeint", "Shield Feint")._types(TYPE_OFFENSIVE)._requisite(REQ_SHIELD)._costs(1), // defered instant before resolution
			new Manuever("netFeint", "Net Feint")._types(TYPE_OFFENSIVE)._requisite(REQ_STUFF, ["Net (Retiarius)"])._costs(1), // defered instant  before resolution
			
			// alt modes
			/**/ new Manuever("buttStrike", "Butt Strike")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_SWING), // unscrewed pommel cannot lowpriorit
			/**/ new Manuever("pommelStrike", "Pommel Strike")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_THRUST)._tn(6)._superior(), // unscrewed pommel cannot lowpriorit
			// alt transforms
			/**/ new Manuever("halfSword", "Half-Sword")._types(TYPE_TRANSFORMATION)._requisite(REQ_WEAPON)._tags(TAG_INSTANT|TAG_ADVANCED)._costs(1),
			/**/ new Manuever("murderStrike", "Murder Strike")._types(TYPE_TRANSFORMATION)._requisite(REQ_WEAPON)._tags(TAG_INSTANT | TAG_ADVANCED)._costs(2),	// Mordhau label
			
			// Initiative
			new StealInitiative(),
			
			// Puglism (trip / kick / knee   ,  Straight punch/ Hook punch/ One-two punch[2] ,  Head butt,  Elbow)
			
			// Ranged (melee shoot/ weapon throw / blind toss)
			/**/ new Manuever("meleeShoot", "Melee Shoot")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_THRUST)._ranged(),
			/**/ new Manuever("weaponThrow", "Weapon Throw")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_THRUST)._ranged(),
			/**/ new Manuever("blindToss", "Blind Toss")._types(TYPE_OFFENSIVE)._requisite(REQ_STUFF)._tn(5)._costs(0,0,true),
			/**/ new Manuever("netToss", "Net Toss")._types(TYPE_OFFENSIVE)._requisite(REQ_STUFF)._ranged(),
			
			// implied unlisted manuevers for reference
			// Ally Defense[2], Quick Defense[2]...  Rapid Rise,Thread the Needle  , Quick draw,
			new Manuever("doNothing", "Do Nothing")._types(0)._superiorInit(function(m){m.name = "Focus"; }),
			new Manuever("masterStrike", "Masterstrike")._types(0)._costs(2)._superior()
			
			// Hilt push: + Lever down[2] / Retreat[2](FLEE?)
			
			/* Guarded attack	  // offhand parries add +2 costs
			 Requirements: Have the means to both attack and defend,
			either armed or unarmed.
			Maneuver: Declare an attack maneuver (X) and a defense
			maneuver (Y).
			Special: If using a defense maneuver with an off-hand weapon 
			or an Arm Parry with the off-hand, pay an additional 2 activation cost unless you have the Ambidextrous boon.
			You cannot use the same weapon to both defend and
			attack using this maneuver—for that you need Masterstrike
			*/
			
			/*
			 * Double Attack [X+Y+1]	// non-ambidextrous offhand double attacks + 1
			Type and Tags: U ATTACK WEAPON SIMULTANEOUS
			Requirements: Using two weapons.
			Maneuver: Declare an attack maneuver with your primary
			hand weapon (X), and your off-hand weapon (Y). These
			maneuvers resolve simultaneously, and must be defended
			against separately.
			Special: If a character has the Ambidextrous boon, this maneuver’s activation cost is reduced to [X+Y].
			*/
			
		];
	}
	
}