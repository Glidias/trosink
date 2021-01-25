package troshx.sos.core;
import troshx.components.Bout;
import troshx.components.FightState;
import troshx.components.FightState.ManueverDeclare;
import troshx.core.IManuever;
import troshx.core.IUid;
import troshx.core.ManueverSpec;
import troshx.sos.bnb.Banes.OneEyed;
import troshx.sos.core.BodyChar.Humanoid;
import troshx.sos.events.SOSEvent;
import troshx.sos.manuevers.*;
import troshx.sos.manuevers.Beat.ShieldBeat;
import troshx.sos.manuevers.Disarm.DisarmUnarmedAtk;
import troshx.sos.manuevers.Disarm.DisarmUnarmedDef;
import troshx.sos.manuevers.PugilisiticAttack.StraightPunch;
import troshx.sos.sheets.CharSheet;
import troshx.util.AbsStringMap;
import troshx.util.LibUtil;
import troshx.util.UidStringMapCreator;

import troshx.sos.manuevers.Beat.ShieldBeat;

import troshx.sos.manuevers.PugilisiticAttack.Elbow;
import troshx.sos.manuevers.PugilisiticAttack.HeadButt;
import troshx.sos.manuevers.PugilisiticAttack.Knee;
import troshx.sos.manuevers.PugilisiticAttack.HookPunch;
import troshx.sos.manuevers.PugilisiticAttack.Kick;
import troshx.sos.manuevers.PugilisiticAttack.Trip;
import troshx.sos.manuevers.PugilisiticAttack.OneTwoPunch;

import troshx.sos.manuevers.NetManuevers.NetToss;
import troshx.sos.manuevers.NetManuevers.NetFeint;

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
	
	public static inline var ORIENTATION_DEFENSIVE:Int = 3;
	public static inline var ORIENTATION_CAUTIOUS:Int = 2;
	public static inline var ORIENTATION_AGGRESSIVE:Int = 1;
	
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
	public function getAvailability(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Bool {
		return true;
	}
	
	
	public static inline var TARGET_ZONE_AUTO:Int = 0;  // determined from attack type
	public static inline var TARGET_ZONE_WEAPON:Int = 1;
	public static inline var TARGET_ZONE_SHIELD:Int = 2;
	public static inline var TARGET_ZONE_OPPONENT:Int = -1;
	
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
		manuever.damage = damage;
		manuever.damageType = damageType;
		manuever.stun = stun;
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
	public static inline var TAG_MOVEMENT:Int = (1 << 11);
	
	
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
	public static inline var NO_INVEST:Int = -1;
	public static inline var DEFER_COST:Int = -2;
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
	
	/**
	 * override this to set max CP invest
	 * @return	A positive value to indicate max allowed to invest. If value is zero, disables availability of manuever.
	 */
	public function getMaxInvest(bout:Bout<CharSheet>, node:FightNode<CharSheet>, spec:ManueverSpec):Int {
		return -1;
	}
	
	
	public var damage:Int = 0;
	public var damageType:Int = -1;
	public var stun:Int = 0;
	@:col public function _damage(type:Int, val:Int, stun:Int=0):Manuever {
		this.damageType = type;
		this.damage = val;
		this.stun = stun;
		return this;
	}
	public inline function hasOwnDamage():Bool {
		return this.damageType >= 0;
	}
	
	public static inline function hasInitiative(node:FightNode<CharSheet>, link:FightLink<CharSheet>):Bool {
		return link.findNodeSide(node) == link.initiative;
	}
	
	public function handleEvent(sheet:CharSheet, fightState:FightState, declare:ManueverDeclare, event:SOSEvent):Bool {
		return false;
	}
	
	public function getCost(bout:Bout<CharSheet>, node:FightNode<CharSheet>, inputs:Array<Int>):Int {
		return cost;
	}
	
	public function resolve(bout:Bout<CharSheet>, node:FightNode<CharSheet>, declare:ManueverDeclare):Void {
		//var manuevers = getMap();
	}

	public function new(id:String, name:String) 
	{
		this.id = id;
		this.name = name;
	}
	
	
	/*
	Availability in terms of:
	
	getAvailability() for manuever itself
	+
	TN availability >=0 sanity check. Requisite + Attack Type (getTN(...)>=0) TN<=1 implies Auto execute/success. Negative TN implies impossible.
	+
	SoS rules: Current usage state (cannot mix unarmed/armed attacks)
	If unarmed attack, only 1 attack manuever allowed. 
	If armed attack, only up to 2 attack manuevers allowed using Double Attack rule
	*/
		
	
	/**
	 * 
	 * @param	bout
	 * @param	node
	 * @param	spec
	 * @return	manuever getTN() value, if negative, denotes impossible manuever
	 */
	public function getTN(spec:ManueverSpec):Int {
		return this.requisites != 0 ? getRequisiteTN(spec) : this.tn;
	}
	
	/**
	 * This function should typically be used if requisites isn't zero to get a relavant conventional manuever TN based on held equipment (if available).
	 * TODO: targetZoneMode check
	 * @param	spec
	 * @return	A default TN based on manuever requisites and manuever spec. If negative number -1, denotes impossible manuever due to lack of requisites.
	 */
	public function getRequisiteTN(spec:ManueverSpec):Int {
		var activeItem:Item = spec.activeItem;
		var req = this.requisites;
		var types = this.types;
		if (spec.typePreference != 0) {
			types = (spec.typePreference & types);
		}
		var shield:Shield = LibUtil.as(activeItem, Shield);
		var weapon:Weapon = LibUtil.as(activeItem, Weapon);
		var reqMilitaryArms:Int = 0;
		reqMilitaryArms |= shield != null ? REQ_SHIELD : 0;
		reqMilitaryArms |= weapon != null ? REQ_WEAPON : 0;
		
		if ((req & REQ_STUFF) != 0) {
			if (activeItem == null) {
				return -1;
			} else if (reqStuffs != null) { // specific named reqStuffs in array to check
				if (reqStuffs.indexOf(activeItem.name) < 0) {
					return -1;
				}
			} else if (req == REQ_STUFF && reqMilitaryArms != 0) { // (exclusively req==REQ_STUFF) requires a non shield/weapon item
				return -1;
			}
		}
		
		// now consider remaining requirements like weapon/shield/unarmed
		req &= (REQ_UNARMED|REQ_WEAPON|REQ_SHIELD);

		if ((req & REQ_UNARMED) !=0) {
			if (activeItem != null && !itemAsUnarmedAllowed(activeItem)) {
				return -1;
			}
		}
		
		req &= (REQ_WEAPON|REQ_SHIELD);
		
		if ( (reqMilitaryArms & req) != req ) {
			trace(name + ', ' + req + ', '+activeItem);
			return -1;
		}
		
		var rtn:Int;
		if ((req & REQ_WEAPON) != 0) {
			if ((types & TYPE_OFFENSIVE)!=0) {
				rtn = isRanged() ? weapon.atnM : 
				spec.activeEnemyBody.isThrusting(spec.activeEnemyZone) ? weapon.atnT : weapon.atnS;
			} else {
				rtn = weapon.dtn;
			}
			if (rtn <= 0) return -1;
			return this.tn > 0 ? this.tn : rtn;
		} else if ((req & REQ_SHIELD) != 0) {
			rtn = (types & TYPE_OFFENSIVE)!=0 ? shield.bashTN : shield.blockTN;
			if (rtn <= 0) return -1;
			return this.tn > 0 ? this.tn : rtn;
		}

		return this.tn;
	}
	
	// override this to define exceptions for held item to be used with unarmed manuever
	public function itemAsUnarmedAllowed(item:Item):Bool {
		return false;
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
			new Manuever("", "")._tn( -1), // null blank manuever
		
			// Swings and thrusts
			new Manuever("swing", "Swing")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_SWING), // greater Swings +1 and +2?
				new DrawCut(),
				new CleavingBlow(),
				
			new Manuever("thrust", "Thrust")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_THRUST),
				new PushCut(),
				new JointThrust(),
			
			// Hooks and feints shared by both swing and thrusts
			new Hook(),
			new Feint(),
			
			// Aim at weapon/shield with weapon
			new Disarm(),
			new Beat(),
			new Break(),
			new Hew(),
			
			// Aim at weapon/shield with shield
			new ShieldBeat(),
			
			//  and unarmed disarms
			new DisarmUnarmedAtk(),

			// Parries
			new Manuever("parry", "Parry")._types(TYPE_DEFENSIVE)._requisite(REQ_WEAPON)._tags(TAG_PARRY),
				new Riposte(),
				new ArmParry(),
				new DisarmUnarmedDef(),
			
			// Voids
			new Manuever("void", "Void")._types(TYPE_DEFENSIVE)._tags(TAG_VOID)._tn(8)._bs(2),
				new HastyVoid(),
				new MobileVoid(),
				new Flee(),
				
			// Blocks
			new Manuever("block", "Block")._types(TYPE_DEFENSIVE)._requisite(REQ_SHIELD)._tags(TAG_BLOCK),
				new ShieldBind(),
				new TotalBlock(),  
			
			// Shield/other alts
			//Swipe Up Shield for sub menu  and tap on Shield Feint as an option. Will revert back to weapon being selected.
			// alt-feints
			new ShieldFeint(),
			new NetFeint(),
			
			// alt modes
			/**/ new Manuever("buttStrike", "Butt Strike")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_SWING), // unscrewed pommel cannot lowpriorit
			/**/ new Manuever("pommelStrike", "Pommel Strike")._types(TYPE_OFFENSIVE)._requisite(REQ_WEAPON)._attackTypes(ATTACK_TYPE_THRUST)._tn(6)._superior(), // unscrewed pommel cannot lowpriorit
			// alt transforms
			/**/ new Manuever("halfSword", "Half-Sword")._types(TYPE_TRANSFORMATION)._requisite(REQ_WEAPON)._tags(TAG_INSTANT|TAG_ADVANCED)._costs(1),
			/**/ new Manuever("murderStrike", "Murder Strike")._types(TYPE_TRANSFORMATION)._requisite(REQ_WEAPON)._tags(TAG_INSTANT | TAG_ADVANCED)._costs(2),	// Mordhau label
			
			// Initiative
			new StealInitiative(),
			
			// Puglism (trip / kick / knee   ,  Straight punch/ Hook punch/ One-two punch[2] ,  Head butt,  Elbow)
			new StraightPunch(),
			new HookPunch(),
			
			new Elbow(),
			new HeadButt(),
	
			new Kick(),
			new Knee(),
			new Trip(),
			
			new OneTwoPunch(),
			
			// Ranged (melee shoot/ weapon throw / blind toss)
			new MeleeShoot(),
			new WeaponThrow(),
			new BlindToss(),
			new NetToss(),
			
			// implied unlisted manuevers for reference
			// Ally Defense[2], Quick Defense[2]...  Rapid Rise,Thread the Needle  , Quick draw,
			new Manuever("doNothing", "Do Nothing")._types(0)._costs(0, NO_INVEST)._superiorInit(function(m){m.name = "Focus"; }),
			new Manuever("masterStrike", "Masterstrike")._types(0)._costs(2)._superior(),
			new Manuever("doubleAttack", "Double Attack")._types(0)._costs(1), // amb == no costs
			new Manuever("doubleShot", "Double Shot")._types(0)._costs(2),
			
			new Manuever("quickDefense", "Quick Defense")._types(0)._costs(2),
			new Manuever("quickDraw", "Quick Draw")._types(0)._costs(1, NO_INVEST)._tags(TAG_INSTANT),
			new Manuever("allyDefense", "Ally Defense")._types(0)._costs(2)._tags(TAG_CROSS_FIGHTING | TAG_INSTANT),
			new Manuever("threadNeedle", "Thread the Needle")._types(0)._tags(TAG_INSTANT|TAG_MOVEMENT),
			new Manuever("rapidRise", "Rapid Rise")._types(0)._tags(TAG_INSTANT|TAG_MOVEMENT)._costs(3, NO_INVEST),
			new Manuever("guardedAttack", "Guarded Attack")._types(0),
			
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
			
			// Grappling
			// Clinch
			
		];
	}
	
}