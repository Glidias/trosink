package troshx.core;
import troshx.core.BodyChar;
import troshx.core.BodyChar.Wound;
import troshx.core.BodyChar.WoundInflict;
import troshx.core.CharSheet.WoundAffliction;
import troshx.tros.ProfeciencySheet;
import troshx.tros.WeaponSheet;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
typedef WoundAffliction = {
	var pain:Int;
	var BL:Int;
	var shock:Int;
	var woundTypes:Int;
	@:optional  var d:Int;
}
class CharSheet
{
// attributes
	// 4 for average human
	
	public function new() {
		
	}
	
	public var name:String;
	
	public var strength:Int;
	public var agility:Int;
	public var toughness:Int;
	public var endurance:Int;
	public var health:Int;
	
	public var willpower:Int;
	public var wit:Int;
	public var mentalapt:Int;
	public var social:Int;
	public var perception:Int;
	
	// weapon and profeciicencies
	public var profeciencies:Dynamic = { };  // object hash consisting of profeciencyId key and skill level value
	public var profeciencyIdCache:String;
	public var bodyType:BodyChar;
	
	public var weapon:Weapon;
	public var weaponOffhand:Weapon;
	
	
	public var wounds:Dynamic<WoundAffliction>;  // object hash to keep track of wounds, their pain,bloodlost and shock... and wound types involved (uses a bitmask),  
	//   using part_id:{}     keyvalue pair  
	// A wound value object goes by  {  pain:?, BL:?, shock:?, woundTypes:? }   
	
	
	public function refreshDefaultProfs():Void {
		var profReference:Dynamic = cloneObj(profeciencies);
		for (p in Reflect.fields(profReference)) {
			var baseScore:Int =  LibUtil.field(profReference, p);// Reflect.field(profReference, p); // profReference[p];
			var prof:Profeciency = ProfeciencySheet.getProfeciency(p);
			//if (prof == null) throw new Error("SHould not be!:"+p);
			if (prof == null) {
				 throw "SHould not be!:"+p;
				//continue;  // excpetion due to incomplete list.
			}
			
			var defaults:Dynamic = prof.defaults;
			for (d in Reflect.fields(defaults) ) {
				if ( ProfeciencySheet.getProfeciency(d) == null) {
					continue;  // exception due to incomplete data entry
				}
				
				var defaultedScore:Int = Std.int( baseScore- LibUtil.field(defaults, d) );
				var curCompareScore:Int = Reflect.hasField(profeciencies, d)  ? Reflect.field(profeciencies,d) : 0;
			
				if (defaultedScore > 6) defaultedScore = 6;
				if (defaultedScore > curCompareScore ) {
					//profeciencies[d] = defaultedScore;
					Reflect.setField(profeciencies, d, defaultedScore);
				}
			}
		}
		//throw new Error( JSON.stringify(profeciencies) );
	}
	
	
	public function clone():CharSheet {  
		var c:CharSheet = new CharSheet();
		c.name = name;
		c.strength = strength;
		c.agility = agility;
		c.toughness = toughness;
		c.endurance = endurance;
		c.health = health;
		
		c.willpower = willpower;
		c.wit = wit;
		c.mentalapt = mentalapt;
		c.social = social;
		c.perception = perception;
		
		c.profeciencies = cloneObj(profeciencies);

		c.weapon = weapon;
		c.weaponOffhand = weaponOffhand;
		c.profeciencyIdCache = profeciencyIdCache;
		
		// NOTE: this clone method does not clone the wounds!
		c.bodyType = bodyType;
		c.wounds = {};
		
		return c;
	}
	
	
	private function cloneObj(obj:Dynamic):Dynamic {
		var o:Dynamic = { };
		for ( p in Reflect.fields(obj)) {
			//o[p] = obj[p];
			Reflect.setField(o, p, Reflect.field(obj, p));
		}

		return o;
	}
	
	
	public function resetAllAttributes(val:Int):Void {
		strength = val;
		agility = val;
		toughness = val;
		endurance = val;
		health = val;
		
		willpower = val;
		wit = val;
		mentalapt = val;
		social = val;
		perception = val;
	}
	
	public function invalidateHandEquipment():Void {
		profeciencyIdCache = null;
	}
	
	
	@:computed("reflex") public function getReflex():Int {
		return Std.int( (agility + wit) / 2 );
	}
	@:computed("aim") public function getAim():Int {
		return Std.int( (agility + perception) / 2 );
	}
	@:computed("knockdown") public function getKnockdown():Int {
		return Std.int( (strength + agility) / 2 );
	}
	@:computed("knockout") public function getKnockout():Int {
		return Std.int( (toughness + (willpower / 2)  ));
	}
	@:computed("speed") public function getSpeed():Float {
		return Std.int( (strength + agility + endurance) / 2);
	}
	
	public function getTotalBloodLost():Int {
		var accum:Int = 0;
		for (p in Reflect.fields(wounds)) {
			var w:Dynamic = Reflect.field(wounds, p);// wounds[p];
			if (w.BL) {
				accum += w.BL;
			}
		}
		return accum;
	}
	
	// listed, blood lost rolls, blood is lost every 6 turns:
	public var bloodLostSoFar:Int = 0;
	
	@:computed("currentHealth") public function getCurrentHealth():Int {
		return health - bloodLostSoFar; // - getTotalBloodLost();
	}
	@:computed public function criticalCondition():Bool {
		return getCurrentHealth() == 1;
	}
	@:computed public function isDeadOrComa():Bool {
		return getCurrentHealth() <= 0;
	}
	@:computed public function canNoLongerFight():Bool {
		return getMeleeCombatPoolAmount() <= 0;
	}
	@:computed public function outOfAction():Bool {
		return  canNoLongerFight() || isDeadOrComa();
	}
	
	
	@:computed("totalPain") public function getTotalPain():Int {
		var accum:Int = 0;
		for (p in Reflect.fields(wounds)) {
			var w:Dynamic = Reflect.field(wounds, p); // wounds[p];
		
			accum += w.pain;
			
		}
		return accum;
		
	}
	
	private function pickBestProfeciency(weapProfs:Array<Dynamic>):String {
		var highestScore:Int = 0;
		var highestProf:String = "";
		
		for (p in Reflect.fields(profeciencies)) {
			for (k in 0...weapProfs.length) {
				var profId:String = weapProfs[k];
				if (profId == p) {
					var score:Int = Reflect.field(profeciencies, profId) ;
					if (score > highestScore) {
						highestScore = score;
						highestProf = profId;
					}
				}
			}
		}
		//if (highestProf != "") throw new Error("A");
		return highestProf;
	}
	
	public function getMeleeProfeciencyId():String {
		// determine best profeciency to use for given set of weaponary
		profeciencyIdCache = "";
		//var hasShield:Boolean = false;
		
		if (weapon!=null) {
			//weapon.profeciencies.indexOf("");
			
			profeciencyIdCache = pickBestProfeciency(weapon.profeciencies);
		}
		else {
			if (weaponOffhand == null  || !weaponOffhand.shield) {
				profeciencyIdCache = "pugilism";
			}
		}
		if (weaponOffhand!=null) {
			//hasShield = weaponOffhand.shield;
		}
		return profeciencyIdCache;
	}
	
	public function getMeleeProfeciencyIdCached():String {
		return profeciencyIdCache != null ? profeciencyIdCache : getMeleeProfeciencyId();
	}
	
	
	public function getMeleeProfeciencyLevel():Int {
		if (profeciencyIdCache == null) profeciencyIdCache = getMeleeProfeciencyId();
		
		return profeciencyIdCache !=  "" ? (Reflect.field(profeciencies, profeciencyIdCache) != null ? Reflect.field(profeciencies, profeciencyIdCache) : 0)  : 0;
	}
	
	public var cpDepletion:Int = 0;
	
	public function getMeleeCombatPoolAmount(carryOverShock:Int=0):Int {
		var amount:Int =  getMeleeProfeciencyLevel() + getReflex() - (cpDepletion = Std.int( Math.max(getTotalPain(), carryOverShock) )); 
		if (amount > 0 && criticalCondition() ) {
			amount = Std.int(amount* .5);
		}
		if (amount < 0) amount = 0;
		return amount;
	}
	
	/**
	 * Determines TN for given manuever of yours based off your character stats/equipment and enemy's manuever(if available), 
	 * and also checks if your manuever is valid/usable as well given those stats/equipment and enemy manuever situation.
	 * @param	manuever	The manuever to check
	 * @param	attacking	Is this an offesnive manuever? Or a defensive one?
	 * @param   enemyManuever  The manuever up are up against, if any, and implies that enemy is attacking. Thus, if you are defending against an enemy attack, this is required.
	 * @param   enemyDiceRolled How much dice the enemy is rolling against you in the given enemy manuever
	 * @param   enemyTargetZone  The target zone the enemy is aiming at in the given enemy manueveer
	 * @return	A valid TN (Target number). If target number is zero, it's assumed the manuever is unusable/invalid!
	 */
	public function getManueverTN(manuever:Manuever, attacking:Bool, enemyManuever:Manuever=null, enemyDiceRolled:Int=0, enemyTargetZone:Int=0):Int {
		if (manuever.defaultTN != 0) {
			return manuever.defaultTN;
		}

		var useWeapon:Weapon;
		
		
		if (attacking) {  
			useWeapon = manuever.offHanded ? weaponOffhand : weapon;
			if (useWeapon == null) useWeapon = getUnarmedWeapon();
			if ( manuever.attackTypes == Manuever.ATTACK_TYPE_STRIKE ) {
				return useWeapon.atn;
			}
			else if (manuever.attackTypes == Manuever.ATTACK_TYPE_THRUST) {
				return useWeapon.atn2;
			}
			else {   // can both perform a strikey and thrustey move
				// if damageType is zero neutral, than assumed no sharp thrusts are available, but can still spike bluntly
				if (manuever.damageType == 0) {
					if (useWeapon.blunt) {
						return useWeapon.atn2 != 0 ? useWeapon.atn2 :  useWeapon.atn;  // consider spiking ATN, if any, otherwise use default ATN
					}
					else {  // cutting only for non-blunt weapons
						return useWeapon.atn;
					}
				}
				else if (manuever.damageType == Manuever.DAMAGE_TYPE_PUNCTURING) {  // if puncturing, assumed thrusting ATN
					return useWeapon.atn2;
				}
				else  {  // assumed Manuever.DAMAGE_TYPE_CUTTING as only option left
					return useWeapon.atn;
				}
			}
			
		}
		else {
			var usingOffhand:Bool = manuever.isDefensiveOffHanded();
			useWeapon =usingOffhand  ? weaponOffhand : weapon;
			if (useWeapon == null) useWeapon = getUnarmedWeapon();
			
			//if (usingOffhand) throw new Error("Using offhand");
			// check for shield limit
			if (usingOffhand && useWeapon.shieldLimit!=0 &&  enemyDiceRolled > useWeapon.shieldLimit  ) {
				// unable to defend against attack because amount of enemy CP used exceeds shield limt
				return 0;
			}
			
			if (manuever.manueverType == Manuever.MANUEVER_TYPE_MELEE) {
				return enemyDiceRolled <= 4 && Manuever.isThrustingMotion(enemyTargetZone, bodyType)  ? 
						(useWeapon.dntT != 0 ? useWeapon.dntT : useWeapon.dtn)  : useWeapon.dtn;
			}
			else return useWeapon.dtn;
			
			
			
			
			
		}
		
		throw "Endpoint reached exception!";
		
		return 0;
	}
	
	private function getUnarmedWeapon():Weapon {
		return WeaponSheet.find("Punch");
	}
	
	public static function createBase(name:String, profeciencies:Dynamic, bodyType:BodyChar, weapon:Weapon=null, weaponOffHand:Weapon=null, baseAttr:Int = 5):CharSheet {
		var c:CharSheet = new CharSheet();
		c.name = name;
		c.wounds = { };
		c.profeciencies = profeciencies;
		c.weapon = weapon;
		c.weaponOffhand = weaponOffHand;
		c.resetAllAttributes(baseAttr);
		c.refreshDefaultProfs();
		c.bodyType = bodyType;
		return c;
	}
	
	public function getAtkZoneDesc(index:Int, weapon:Weapon=null):String 
	{
		if (weapon == null) weapon = getUnarmedWeapon();
		var zoneArr:Array<ZoneBody> = weapon.blunt ? bodyType.zonesB : bodyType.zones;
		return zoneArr[index].name;
	}
	
	public function getPrimaryWeaponUsed():Weapon 
	{
		return weapon != null ? weapon : getUnarmedWeapon();
	}
	
	public function inflictWound(level:Int, manuever:Manuever, weapon:Weapon, targetZone:Int):Dynamic 
	{
		var painInflicted:Int;
		var shockInflicted:Int;
		
		//Math.random() * 6;
		if (level > 5) {
			
			throw "should not be level >5";
			level = 5;
		}
		var wound:WoundInflict = bodyType.getWound(level, manuever, weapon, targetZone);
		if (wound == null) return null;

		var existingWound:WoundAffliction = Reflect.hasField(wounds, wound.part)  ? LibUtil.field(wounds, wound.part) : LibUtil.setFieldChain(wounds, wound.part, { pain:0, BL:0, shock:0, woundTypes:0 });
		// {"KD":3,"BL":0,"shock":4,"shockWP":0,"pain":6,"painWP":1, d:.}
		existingWound.woundTypes |= wound.type;
		var woundEntry:Wound = wound.entry;
		
		// later: not sure how to handle ALL cases, need to check the rules
		if (woundEntry.shock == -1) {  
			shockInflicted = getMeleeProfeciencyLevel() + getReflex();
		}
		else {
			shockInflicted = woundEntry.shock;
		}
		
		if (woundEntry.pain == -1) {  
			painInflicted = getMeleeProfeciencyLevel() + getReflex();
		}
		else {
			painInflicted = woundEntry.pain;
		}
		shockInflicted -= woundEntry.shockWP * willpower;
		painInflicted -= woundEntry.painWP * willpower;
		
		if (painInflicted > existingWound.pain) {
			existingWound.pain = painInflicted;
		}
		if (shockInflicted > existingWound.shock) {
			existingWound.shock = shockInflicted;
		}
		if (woundEntry.BL > existingWound.BL) {
			existingWound.BL = woundEntry.BL;
		}
		existingWound.d = woundEntry.d;  
		
		if (Math.isNaN(shockInflicted)) throw ("SHock inflicted is NAN:"+wound.part+", "+level);
		wound.shock = shockInflicted;
		wound.d = woundEntry.d;
		
		
		return wound;
	}
	
	/*
	public function inflictMargin(weapon:Weapon, manuever:Manuever, targetZone:int, margin:int, from:CharacterSheet):void 
	{
		weapon.getDamageTo(bodyType, manuever, targetZone, margin, from);
	}
	*/
	
	
}