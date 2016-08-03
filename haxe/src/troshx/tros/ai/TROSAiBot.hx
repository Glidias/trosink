package troshx.tros.ai;
import troshx.BodyChar;
import troshx.tros.Weapon;
import troshx.util.TROSAI;

/**
 * Basic AI Bot automation module for both human players and AI characters for The Riddle of Steel
 * @author Glidias
 */
@:expose
//@:rtti
class TROSAiBot
{
	// Opponents that are targeting you...for choosing manuever 1,2,and 3 respectively
	private var opponents:Array<TROSAiBot> = [];
	private var opponentLen:Int = 0;
	private var cpBudget:Array<Int> = [];
	
	private var plannedCombos:Array<Int>  = [0, 0, 0, 0];
	private var currentExchange:Int = 0;
	
	// Character sheet ?
	@link public var body:BodyChar;
	//@link public var armorValues::Dynamic<Float>
	@bind("_cp") public var cp:Int;
	@bind("_equipMasterhand") public var equipMasterhand:String;
	@bind("_equipOffhand") public var equipOffhand:String;
	
	// Combat related
	@bind("_id") public var id:Int;
	@bind("_fight_initiative") public var initiative:Bool;
	@bind("_fight_stance") public var stance:Int;
	
	public var decidedStance:Int;
	public var decidedOrientation:Int;
	public var decidedManuevers:Array<AIManueverChoice>  = [null, null, null, null];
	

	public function getDecidedManueverForSlot(slot:Int):String {
		return decidedManuevers[slot] != null ? decidedManuevers[slot].manuever : "";
	}
	public function getDecidedManueverCP(slot:Int):Int {
		return decidedManuevers[slot] != null ? decidedManuevers[slot].manueverCP : 0;
	}
	public function getDecidedManueverTargetZone(slot:Int):Int {
		return decidedManuevers[slot] != null ? decidedManuevers[slot].targetZone : 0;
	}
	
	// all recorded attack action availabilities as  (cost - 1) for actual cost
	@bind public static var AVAIL_bash = 0; 
	@bind public static var AVAIL_spike = 0;  
	@bind public static var AVAIL_cut = 0;	
	@bind public static var AVAIL_thrust = 0;
	@bind public static var AVAIL_beat = 0;
	@bind public static var AVAIL_bindstrike = 0;

	// all recorded defend actoin availabilities  as  (cost - 1) for actual cost
	@bind public static var AVAIL_block = 0;
	@bind public static var AVAIL_parry = 0;
	@bind public static var AVAIL_duckweave = 0;
	@bind public static var AVAIL_partialevasion = 0;
	@bind public static var AVAIL_fullevasion = 0;
	@bind public static var AVAIL_blockopenstrike = 0;
	@bind public static var AVAIL_counter = 0;
	@bind public static var AVAIL_rota = 0;
	@bind public static var AVAIL_expulsion = 0;
	@bind public static var AVAIL_disarm = 0;
	
	@bind public static var B_EQUIP:String = "";  // master/off-hand offense in context
	@bind public static var D_EQUIP:String = "";  // offhand defense in context
	
	// basic ai combos with initiative:
	private static inline var COMBO_PureMeanStrikes:Int = 1; // Pure Mean Strikes
	private static inline var COMBO_HeavyFirstStrikes:Int = 2; // Heavy-First Mean strikes
	private static inline var COMBO_AlphaDisarm:Int = 3; // Alpha Disarm
	private static inline var COMBO_AlphaHookStrike:Int = 4; // Alpha Hook Strike
	private static inline var COMBO_AlphaStrike:Int = 5; 	// Alpha Strike
	private static inline var COMBO_BeatStrike:Int = 6; // Beat Strike
	private static inline var COMBO_BindAndStrike:Int = 7; // Bind and Strike
	private static inline var COMBO_FeintStrike:Int = 8;  // Feint Strike
	private static inline var COMBO_DoubleAttack:Int = 9;  // Double Attack	
	private static inline var COMBO_SimulatenousBlockStrike:Int = 10;  // Simulatenous Block and Strike
	
	// basic ai combos without initiative:
	private static inline var COMBO_DefensiveFirst:Int = -1;  // Defensive-first
	private static inline var COMBO_AlphaInitiativeStealer:Int = -2;  // Alpha Initiative Stealer
	private static inline var COMBO_AlphaDisarmDef:Int = -3;  // Alpha Disarm
	private static inline var COMBO_SimulatenousBlockStrikeStealer:Int = -4;  // Simultaneous Block-Strike Initiative Stealer 
	
	
	
	private static var B_CANDIDATES:Array<String> = [];
	private static var B_CANDIDATE_COUNT:Int = 0;
	
	/**
	 * Tries to heuristically choose "best" regular attack manuever
	 * @param	availableCP	Your available CP for use
	 * @param	roll	 (Optional) Indicates number of dice (likely) to roll. If left blank, uses entire availableCP.
	 * @param	againstRoll (Optional)  Indicates number of enemy dice (likely) to roll against.
	 * @param	againstTN (Optional)  Indicates (likely) enemy TN to roll against
	 * @return	The manuever id string
	 */
	public static function getRegularAttack(availableCP:Int, roll:Int = 0,  againstRoll:Int = -1, againstTN:Int=1):String {
	
		B_CANDIDATE_COUNT = 0;
		var weapon:Weapon = WeaponSheet.getWeaponByName(B_EQUIP);
		var tn:Int = weapon != null ? weapon.atn : 888;
		var tn2:Int = weapon != null ?  weapon.atn2 : 888;
		var cost:Int;
		var aggr:Float;
		
		if ( roll == 0) roll = availableCP;
		
		var tnP:Float = TROSAI.getTNSuccessProbForDie(tn);
		var tn2P:Float = TROSAI.getTNSuccessProbForDie(tn2);
		
		var dmg:Float = weapon != null && againstRoll >= 0 ? weapon.damage : 0;
		var dmgT:Float = weapon != null && againstRoll >= 0 ? weapon.damageT : 0;
		var probabilityToHitSlash:Float =  againstRoll >= 0 ? TROSAI.getChanceToSucceedContest(roll, tn, againstRoll, againstTN, 1) : 0;
		var probabilityToHitThrust:Float =  againstRoll >= 0 ? TROSAI.getChanceToSucceedContest(roll, tn2, againstRoll, againstTN, 1) : 0;
		
		var aggrCur:Float = -999; 	// current rough aggregate considering TN, activation cost, and weapon damage in relation to dices being rolled

		if ( AVAIL_bash != 0) {
			
			cost = AVAIL_bash - 1;
			if (cost < availableCP) {
				aggr = tnP * (roll - cost) + probabilityToHitSlash*dmg;
			
				if ( aggr >= aggrCur) {
					B_CANDIDATES[B_CANDIDATE_COUNT++] = "bash";
				}

			}
		}
		if ( AVAIL_cut != 0) {
			cost = AVAIL_cut - 1;
			 if (cost < availableCP) {
				aggr = tnP*(roll-cost) + probabilityToHitSlash*dmg;
				if ( aggr >= aggrCur ) {
					B_CANDIDATES[B_CANDIDATE_COUNT++] = "cut";
				}
			
			
			}
		}
		if ( AVAIL_spike != 0) { 
			cost = AVAIL_spike - 1;
			if (cost < availableCP) {
				aggr = tn2P*(roll-cost) + probabilityToHitThrust*dmgT;
				if ( aggr >= aggrCur ) {
						B_CANDIDATES[B_CANDIDATE_COUNT++] = "spike";
				}
				
			}
		}
		
		if ( AVAIL_thrust != 0) {
			cost = AVAIL_thrust - 1;
			if (cost < availableCP) {
				aggr = tn2P*(roll-cost) + probabilityToHitThrust*dmgT;
				
				if (aggr >= aggrCur ) {
					B_CANDIDATES[B_CANDIDATE_COUNT++] = "thrust";
				}
				
			}
		}
		
		
		
		
		if (B_CANDIDATE_COUNT == 0) return null;
		
		
		
		return B_CANDIDATES[Std.int(Math.random()*B_CANDIDATE_COUNT)];
	}
	
	/**
	 * Tries to heuristically choose "best" regular defense manuever
	 * @param	availableCP	 Your available CP for use
	 * @param	roll (Optional) Indicates number of dice (likely) to roll. If left blank, uses entire availableCP.
	 * @param   enforceMustRegainInitiative  (Optional) If set to true, defensive manuevers that have no means of regaining back initiative would be omitted. 
	 * @return	The manuever id string
	 */
	public static function getNaiveRegularDefense(availableCP:Int, roll:Int = 0, enforceMustRegainInitiative:Bool=false):String {
		
		B_CANDIDATE_COUNT = 0;
			
		var weapon:Weapon = WeaponSheet.getWeaponByName(B_EQUIP);
		var offhand:Weapon = WeaponSheet.getWeaponByName(D_EQUIP);
		
		var tn:Int = weapon != null ? weapon.dtn : 888;
		var tnOff:Int = offhand != null ? offhand.dtn : 888;
		var tnP:Float = TROSAI.getTNSuccessProbForDie(tn);
		var tnPOff:Float = TROSAI.getTNSuccessProbForDie(tnOff);
			
		var aggr:Float; 
		var aggrCur:Float = -999; 	// current rough aggregate considering TN, activation cost, in relation to dices being rolled
		
		
		if ( roll == 0) roll = availableCP;
		
		var cost:Int;
		
		
		if (AVAIL_block != 0) {
			cost = AVAIL_block - 1;
			if (cost < roll) {
				aggr = tnPOff * (roll - cost);
				if (aggr >= aggrCur) {
					B_CANDIDATES[B_CANDIDATE_COUNT++] = "block";
				}
			}
		}
		
		if (AVAIL_parry != 0) {
			cost = AVAIL_parry - 1;
			if (cost < availableCP) {
				aggr = tnP * (roll - cost);
				if (aggr >= aggrCur) {
					B_CANDIDATES[B_CANDIDATE_COUNT++] = "parry";
				}
			}
		}
		
		if (AVAIL_partialevasion != 0) { 
			cost = AVAIL_partialevasion - 1;
			if (cost  + (enforceMustRegainInitiative ? 2 : 0) < availableCP) {
				aggr = tnP * (roll - cost);
				if (aggr >= aggrCur) {
					B_CANDIDATES[B_CANDIDATE_COUNT++] = "partialevasion";
				}
			}
		}
		
		if (B_CANDIDATE_COUNT == 0) return null;
		
		return B_CANDIDATES[Std.int(Math.random()*B_CANDIDATE_COUNT)];
	
	}
	
	// basic ai individual manuever actions:
	
	// Favorable Attack
	// Favorable Defense
	// Borderline Attack
	// Borderline Defense
	// Block Open and Strike
	// Rota/Counter
	// Disarm
	// Hook
	private static var MANUEVER_CHOICE:AIManueverChoice  = new AIManueverChoice();

	public static function getFavorableAttack(availableCP:Int, againstCP:Int, againstRoll:Int = 0, againstTN:Int=1, secondExchange:Bool = false):Bool {
		
		return false;
	}
	public static function getFavorableDefense(availableCP:Int, againstCP:Int,  againstRoll:Int=0,  againstTN:Int=1, secondExchange:Bool=false):Bool {
		return false;
	}
	public static function getBorderlineAttack(availableCP:Int, againstCP:Int,  againstRoll:Int=0,  againstTN:Int=1, secondExchange:Bool=false):Bool {
		return false;
	}
	public static function getBorderlineDefense(availableCP:Int, againstCP:Int,  againstRoll:Int=0,  againstTN:Int=1, secondExchange:Bool=false):Bool {
		return false;
	}
	public static function getBlockOpenAndStrike(availableCP:Int, againstCP:Int, againstRoll:Int=0,  againstTN:Int=1, secondExchange:Bool=false):Bool {
		return false;
	}
	public static function getRotaOrCounter(availableCP:Int, againstCP:Int, againstRoll:Int=0,  againstTN:Int=1, secondExchange:Bool=false):Bool {
		return false;
	}
	public static function getDisarm(availableCP:Int, againstCP:Int, againstRoll:Int=0,  againstTN:Int=1, secondExchange:Bool=false):Bool {
		return false;
	}
	public static function getHook(availableCP:Int, againstCP:Int, againstRoll:Int=0,  againstTN:Int=1, secondExchange:Bool=false):Bool {
		return false;
	}
	public static function getBeat(availableCP:Int, againstCP:Int, againstRoll:Int=0,  againstTN:Int=1, secondExchange:Bool=false):Bool {
		return false;
	}
	public static function getBindStrike(availableCP:Int, againstCP:Int,  againstRoll:Int=0,  againstTN:Int=1, secondExchange:Bool=false):Bool {
		return false;
	}
	
	// Combo action getter
	
	private static function getComboAction(combo:Int, cp:Int, cp2:Int, vsRoll:Int=0, secondExc:Bool = false, secondInitiative:Bool=false):Bool {
		switch( combo) {
				// ai combos with initiative:
				case COMBO_PureMeanStrikes:
					
				case COMBO_HeavyFirstStrikes:
				case COMBO_AlphaDisarm:
				case COMBO_AlphaHookStrike:
				case COMBO_AlphaStrike:
				case COMBO_BeatStrike:
				case COMBO_BindAndStrike:
				case COMBO_FeintStrike:
				case COMBO_DoubleAttack:
				case COMBO_SimulatenousBlockStrike:
				
				// ai combos without initiative:
				case COMBO_DefensiveFirst:
				case COMBO_AlphaInitiativeStealer:
				case COMBO_AlphaDisarmDef:
				case COMBO_SimulatenousBlockStrikeStealer:
		}
		return false;
	}
	
	
	public function new() 
	{
		
	}

	
	// Standard public interface
	
	public function newExchange(newRound:Bool=false):Void {
		for (i in 0...decidedManuevers.length) {
			decidedManuevers[i] = null;
		}
		
		if (newRound) {
			currentExchange =  1;
			for (i in 0...decidedManuevers.length) {
				plannedCombos[i] = 0;
				
			}
		}
		else {
			currentExchange = 2;
		}
	}
	
	public function decideStance(enemies:Array<TROSAiBot>, target:TROSAiBot, targetedBy:Array<TROSAiBot>):Void {
		
	}
	
	public function decideOrientation(enemies:Array<TROSAiBot>, target:TROSAiBot, targetedBy:Array<TROSAiBot>):Void {
		
	}
	
	public function decideTarget(enemies:Array<TROSAiBot>):Void {
		
	}
	
	public function preDeclareManuevers(target:TROSAiBot, targetedBy:Array<TROSAiBot>):Void {
		// update
		opponents[0] = target;
		var count:Int = 1;
		var totalOpponentCP:Float = 0;
		for (i in 0...targetedBy.length) {
			if (targetedBy[i] != target) {
				opponents[count++] = targetedBy[i];
				totalOpponentCP += targetedBy[i].cp;
			}
		}
		opponentLen = count;
		for (i in opponentLen...opponents.length) {
			opponents[i] = null;
		}
		
		// budget CPs against opponents (lol, AI is psychic here and knows the exact CP others hav....not a very fair premise atm...)
		var cpLeft:Int = cp;
		for (i in 0...opponentLen) {
			var cpToAssign:Int = Std.int( Math.min( cpLeft, Math.ceil( opponents[i].cp / totalOpponentCP *  cp ) ) );
			cpBudget[i] =  cpToAssign;
			cpLeft -= cpToAssign;
		}
		
	}
	
	public function declareManuevers():Void {
		for (i in 0...opponentLen) {
			declareManueverAgainstOpponent(i);
		}
	}
	
	
	// -----
	
	
	
	public function declareManueverAgainstOpponent(index:Int):Bool {
		
		// Determine CP and threat from opponent
		
		var cpAvailable:Int = cpBudget[index];
		var cpAvailable2:Int;
		var opponent:TROSAiBot = opponents[index];
		var threatManuever:AIManueverChoice = null;

		var threatManuever2:AIManueverChoice = null;
		
		if (opponent.decidedManuevers[0] != null && opponent.decidedManuevers[0].againstID == id ) {
			threatManuever = opponent.decidedManuevers[0];
		}
		else if (opponent.decidedManuevers[0] == null) {  // declaring with initiative
			
		}
		
		if (opponent.decidedManuevers[1]!=null && opponent.decidedManuevers[1].againstID == id) {  // for handling double/secondary attack cases
			if (threatManuever != null) {
				threatManuever2 = opponent.decidedManuevers[1];
			}
			else {
				threatManuever  =opponent.decidedManuevers[1];
			}
		}
		
		if (threatManuever2 != null) {
			// assign cpAvailable2 from cpAvailable
		}
		
		// Determine manuever
		
		if (currentExchange != 2) {  // consider a specific combo, assumed exchange 1
			if (initiative) {
				// decide on best combo with initiative
				
			}
			else {
				// decide on best cobo without initaitive
			}
		}
		else {		// assumed exchange 2
			// if got combo, use 2nd action for combo
			if ( plannedCombos[index] != 0 ) {
				if ( getComboAction( plannedCombos[index], cp, opponent.cp, (threatManuever != null ? threatManuever.manueverCP : 0), true, initiative) ) {
					return true;
				}
			}
			
		}
		
		// use fallback action here
		
		return false;
	}
	
	
}