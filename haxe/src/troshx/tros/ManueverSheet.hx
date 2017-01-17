package troshx.tros;
import haxe.ds.StringMap;
import troshx.components.FightState.ManueverDeclare;
import troshx.core.Manuever;

/**
 * ...
 * @author Glidias
 */
@:expose
class ManueverSheet
{

		private static var offensiveMelee:Array<Manuever> = setAsOffensiveList([
			new Manuever("cut", "Cut")._dmgType(Manuever.DAMAGE_TYPE_CUTTING)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)
			,new Manuever("cut2", "Greater Cut", 1)._dmgType(Manuever.DAMAGE_TYPE_CUTTING)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._customDamage(damageMod_add1)
		,new Manuever("bash", "Bash")._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)
			,new Manuever("bash2", "Greater Bash", 1)._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._customDamage(damageMod_add1)
			,new Manuever("beat", "Beat")._lev(4)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._customRequire()._customResolve()
			,new Manuever("bindstrike", "Bind and Strike")._customRequire()._customResolve()
						,new Manuever("thrust", "Thrust")._customReflex()._dmgType(Manuever.DAMAGE_TYPE_PUNCTURING)._atkTypes(Manuever.ATTACK_TYPE_THRUST)
		,new Manuever("spike", "Spike")._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._atkTypes(Manuever.ATTACK_TYPE_THRUST)
		,new Manuever("spike2", "Greater Spike", 1)._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._atkTypes(Manuever.ATTACK_TYPE_THRUST)._customDamage(damageMod_add1)
					,new Manuever("punch", "Punch")._tn(5)._range(1)._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._customDamage()
		,new Manuever("kick", "Kick")._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._tn(7)._customDamage()._range(2)._regions(0)._rangeMin(1)
		
		,new Manuever("disarm", "Disarm", 1)._lev(4)._customRequire()._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._customResolve()
			,new Manuever("doubleattack", "Double Attack")._customRequire()._customSplit()
			,new Manuever("drawcut", "Draw Cut")._lev(2)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._dmgType(Manuever.DAMAGE_TYPE_CUTTING)._customDamage()._customRange()._customRequire()
			,new Manuever("evasiveattack", "Evasive Attack")._lev(6)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._customRequire()._customPreResolve()
		,new Manuever("feintandthrust", "Feint and Thrust")._lev(3)._atkTypes(Manuever.ATTACK_TYPE_THRUST)._customPreResolve()._spamPenalize(1, true)  //_dmgType(Manuever.DAMAGE_TYPE_PUNCTURING).
		,new Manuever("feintandcut", "Feint and Cut")._lev(5)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._customPreResolve()._spamPenalize(1, true)  //_dmgType(Manuever.DAMAGE_TYPE_CUTTING)
		,new Manuever("grapple", "Grapple")._tn(5)._customResolve()
		//,new Manuever("halfsword", "Half Sword")._customResolve()
		,new Manuever("headbutt", "Head Butt")._tn(6)._range(1)._regions(0)._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._customDamage() 
		,new Manuever("hook", "Hook")._customResolve()._regions(0)
		,new Manuever("masterstrike", "Master Strike")._lev(15)._customRequire()._customSplit()
		,new Manuever("murderstroke", "Murder Stroke")._lev(5)._tn(6)._range(1)._customRequire()._regions(0)._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._atkTypes(Manuever.ATTACK_TYPE_STRIKE)._customPreResolve()._customDamage()
		,new Manuever("pommelbash", "Pommel Bash")._lev(5)._tn(7)._range(1)._customRequire()._dmgType(Manuever.DAMAGE_TYPE_BLUDGEONING)._customDamage()
		,new Manuever("quickdraw", "Quick Draw")._lev(6)._customResolve()
		,new Manuever("blockstrike", "Block & Strike")._customRequire()._customSplit()._stanceModifier(0)
		,new Manuever("stopshort", "Stop Short")._lev(3)._customResolve()._spamPenalize(1)	
		,new Manuever("toss", "Toss")._customRequire()._tn(7)._customResolve()
		,new Manuever("twitching", "Twitching")._lev(8)._customSplit()._customResolve()
		]);
		
		private static var defensiveMelee:Array<Manuever>= setAsDefensiveList([ // NOTE: full evade must always be the first. In fact, first 3 should be evasive manuevers by convention
			new Manuever("block", "Block")._atkTypes(Manuever.DEFEND_TYPE_OFFHAND)//._customRequire()
			,new Manuever("parry", "Parry")._atkTypes(Manuever.DEFEND_TYPE_MASTERHAND)
			,new Manuever("fullevade", "Full Evasion")._tn(4)._stanceModifier(0)._evasive(Manuever.EVASIVE_NO_INITAITIVE_MUTUAL|Manuever.EVASIVE_UNTARGET_MUTUAL)  // staionery full evade is possible (ie. didn't displace)...but need terrain roll TN7 saving throw
			,new Manuever("partialevade", "Partial Evasion")._tn(7)._evasive(Manuever.EVASIVE_NO_INITAITIVE) //._customResolve()  // partial buying initiative will cost 2cp only, post _customPostResolve, non-standard
			,new Manuever("duckweave", "Duck & Weave")._tn(9)._customResolve()._evasive(0)
			
			,new Manuever("blockopenstrike", "Block Open and Strike")._lev(6)._atkTypes(Manuever.DEFEND_TYPE_OFFHAND)._customResolve()._stanceModifier(0)
			,new Manuever("counter", "Counter")._atkTypes(Manuever.DEFEND_TYPE_MASTERHAND)._customResolve()
			,new Manuever("disarm", "Disarm", 1)._lev(4)._atkTypes(Manuever.DEFEND_TYPE_MASTERHAND)._customResolve()
			,new Manuever("expulsion", "Expulsion")._lev(5)._atkTypes(Manuever.DEFEND_TYPE_MASTERHAND)._customResolve()
			,new Manuever("grapple",  "Grapple")._tn(5)._customResolve()
		//	,new Manuever("halfsword", "Half Sword").
			,new Manuever("masterstrike", "Master Strike")._lev(15)._customRequire()._customSplit()
			,new Manuever("overrun", "Overrun")._lev(12)._tn(7)._customSplit()
			
			,new Manuever("quickdraw", "Quick Draw")._lev(6)._atkTypes(Manuever.DEFEND_TYPE_MASTERHAND)._customResolve()
			,new Manuever("rota", "Rota")._customRequire()._lev(3)._atkTypes(Manuever.DEFEND_TYPE_MASTERHAND)._customResolve()

		]);
		public static var offensiveMeleeHash:StringMap<Int> = createHashIndex(offensiveMelee);
		public static var defensiveMeleeHash:StringMap<Int> = createHashIndex(defensiveMelee);
		
		private static function setAsDefensiveList(arr:Array<Manuever>):Array<Manuever> {
			var i:Int = arr.length;
			while (--i > -1) {
				arr[i].type = Manuever.TYPE_DEFENSIVE;
			}
			return arr;
		}
		private static function setAsOffensiveList(arr:Array<Manuever>):Array<Manuever> {
			var i:Int = arr.length;
			while (--i > -1) {
				arr[i].type = Manuever.TYPE_OFFENSIVE;
			}
			return arr;
		}
		
		static public function isDamagingManuever(ms:String) 
		{
			// todo: proper manuever parameter
			return ms == "cut" || ms == "spike" || ms == "thrust" || ms == "bash";
		}	

		public static function damageMod_add1(damage:Int, cManuever:ManueverDeclare):Int {
			return damage + 1;
		}
	
		public static function emptyResolveMethod():Void {
			
		}
		
		public static function getDefensiveManueverById(id:String):Manuever {
			return defensiveMelee[defensiveMeleeHash.get(id)];
		}
		public static function getOffensiveManueverById(id:String):Manuever {
			return offensiveMelee[offensiveMeleeHash.get(id)];
		}
		public static function createHashIndex(arr:Array<Manuever>):StringMap<Int> {
			var obj:StringMap<Int> = new StringMap<Int>();
			
			for (i in 0...arr.length) {
			//	obj[arr[i].id] = i;
				obj.set(arr[i].id, i);
			}
			return obj;
		}
		
		
		
		//public static function createOffensive
		
		public static function getMaskWithHashIndexer(arrOfIds:Array<String>, hash:StringMap<Int>):UInt {
			var val:UInt = 0;
			var i:Int = arrOfIds.length;
			while (--i > -1) {
				var prop:String =  arrOfIds[i];
				if ( hash.exists(prop) ) val |= (1 << hash.get(prop)  );
			}
			return val;
		}
		
		public static function createOffensiveMeleeMaskFor(arr:Array<String>):UInt {
			return getMaskWithHashIndexer(arr, offensiveMeleeHash);
		}
		
		public static function createDefensiveMeleeMaskFor(arr:Array<String>):UInt {
			return getMaskWithHashIndexer(arr, defensiveMeleeHash);
		}
		
		static public inline function getManueverListArray(attacking:Bool):Array<Manuever>
		{
			return attacking ? offensiveMelee : defensiveMelee;
		}	
		
	
	
}