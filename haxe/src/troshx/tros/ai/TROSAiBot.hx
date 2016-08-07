package troshx.tros.ai;
import haxe.ds.Vector;
import haxe.ds.Vector;
import troshx.BodyChar;
import troshx.tros.Manuever;
import troshx.tros.Weapon;
import troshx.tros.WeaponSheet;
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
	@bind("_manueverUsingHands") public var manueverUsingHands:Int = 0;
	
	private var handsUsedUp:Int;
	
	public var decidedStance:Int;
	public var decidedOrientation:Int;
	public var decidedManuevers:Array<AIManueverChoice>  = [new AIManueverChoice(), new AIManueverChoice(), new AIManueverChoice(), new AIManueverChoice()];
	

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
	
	@bind public static var AVAIL_StealInitiative = 5;
	private static inline function getCostOfAVAIL(avail:Int):Int {
		return avail - 1;
	}
	
	private static function getCostOfManuever(manuever:String):Int
	{
		switch( manuever) { 
			case "bash": return AVAIL_bash-1; 
			case "spike": return AVAIL_spike -1;   
			case "cut": return AVAIL_cut -1; 
			case "thrust": return AVAIL_thrust -1; 
			case "beat": return AVAIL_beat -1; 
			case "bindstrike": return AVAIL_bindstrike-1; 

			// all recorded defend actoin availabilities  as  (cost - 1) for actual cost
			case "block": return AVAIL_block -1; 
			case "parry": return AVAIL_parry -1; 
			case "duckweave": return AVAIL_duckweave-1; 
			case "partialevasion": return AVAIL_partialevasion-1; 
			case "fullevasion": return AVAIL_fullevasion-1; 
			case "blockopenstrike": return AVAIL_blockopenstrike -1; 
			case "counter": return AVAIL_counter-1; 
			case "rota": return AVAIL_rota-1; 
			case "expulsion": return AVAIL_expulsion-1; 
			case "disarm": return AVAIL_disarm - 1; 
		}
		return 0;
	
	}
	
	

	private static var B_EQUIP:String = "";  // master  equip
	private static var B_IS_OFFHAND:Bool = false;
	private static var D_EQUIP:String = "";  // offhand equip
	// mock budgets
	private static var B_COMBO_EXCHANGE_BUDGET:Vector<Int>  = new Vector<Int>(4);
	private static inline var BUDGET_EXCHANGE_1:Int = 0;
	private static inline var BUDGET_EXCHANGE_1_ENEMY:Int = 1;
	private static inline var BUDGET_EXCHANGE_2:Int = 2;
	private static inline var BUDGET_EXCHANGE_2_ENEMY:Int = 3;

	
	private static var CURRENT_OPPONENT:TROSAiBot;
	
	
	
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
	private static inline var COMBOS_LEN_INITIATIVE:Int = 10;
	
	// basic ai combos without initiative
	private static inline var COMBO_DefensiveFirst:Int = -1;  // Defensive-first
	private static inline var COMBO_AlphaInitiativeStealer:Int = -2;  // Alpha Initiative Stealer
	private static inline var COMBO_AlphaDisarmDef:Int = -3;  // Alpha Disarm
	private static inline var COMBO_SimulatenousBlockStrikeStealer:Int = -4;  // Simultaneous Block-Strike Initiative Stealer 
	private static inline var COMBOS_LEN_NO_INITAITIVE:Int = 4;
	
	public static var P_THRESHOLD_FAVORABLE:Float = 0.75;
	public static var P_THRESHOLD_BORDERLINE:Float = 0.5;
	
	
	
	private static var B_CANDIDATES:Array<String> = [];
	private static var B_CANDIDATE_COUNT:Int = 0;
	private static var B_BS_REQUIRED:Int = 1; // required BS required in current context
	private static var B_VIABLE_PROBABILITY:Float;
	private static var B_VIABLE_PROBABILITY_GET:Float;
	
	private static var B_COMBO_CANDIDATES:Array<Int> = [];
	private static var B_COMBO_CANDIDATE_MANUEVER:Array<AIManueverChoice> = [];

	private static var B_COMBO_CANDIDATE_COUNT:Int = 0;

	
	/**
	 * Tries to heuristically choose "best" regular attack manuever
	 * @param	availableCP	Your available CP for use
	 * @param	roll	 (Optional) Indicates number of dice (likely) to roll. If left blank, uses entire availableCP.
	 * @param	againstRoll (Optional)  Indicates number of enemy dice (likely) to roll against.
	 * @param	againstTN (Optional)  Indicates (likely) enemy TN to roll against
	 * @return	The manuever id string
	 */
	@inspect
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
	@inspect
	public static function getRegularDefense(availableCP:Int, roll:Int = 0, enforceMustRegainInitiative:Bool=false):String {
		
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
				aggr = TROSAI.getTNSuccessProbForDie(7) * (roll - cost);
				if (aggr >= aggrCur) {
					B_CANDIDATES[B_CANDIDATE_COUNT++] = "partialevasion";
				}
			}
		}
		
		if (B_CANDIDATE_COUNT == 0) return null;
		
		return B_CANDIDATES[Std.int(Math.random()*B_CANDIDATE_COUNT)];
	}
	
	// considerTODO: this should be factored out into ManuverSheet method
	private static function getATNOfManuever(manuever:String):Int {
		var weapon:Weapon = WeaponSheet.getWeaponByName(B_EQUIP);
		var tn:Int = weapon != null ? weapon.atn : 888;
		var tn2:Int = weapon != null ?  weapon.atn2 : 888;
		var cost:Int;
		var aggr:Float;
	
		switch(manuever) {
			case "bash": return tn;
			case "cut": return tn;
			case "spike": return tn2;
			case "thrust": return tn2;
		}
		return 0;
	}
	
	
	private static function getDTNOfManuever(manuever:String):Int {
		var weapon:Weapon = WeaponSheet.getWeaponByName(B_EQUIP);
		var offhand:Weapon = WeaponSheet.getWeaponByName(D_EQUIP);
		
		var tn:Int = weapon != null ? weapon.dtn : 888;
		var tnOff:Int = offhand != null ? offhand.dtn : 888;
		
		switch(manuever) {
			case "block": return tnOff;
			case "parry": return tn;
			case "partialevasion": return 7;
		}
		
		return 0;
	}
	
	
	
	public static function getRegularTargetZone(atn:Int, cp:Int):Int {
		
	
		var zones = CURRENT_OPPONENT.body.zones; 
		var randIndex:Int = 1 + Std.int( Math.random() * (zones.length - 1) );
		
		return randIndex;
		
		// TODO: consider armor and the like
		for (i in 1...zones.length) {
			
		}
		
		
		return 0;
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
	private static var MANUEVER_CHOICE_SET:AIManueverChoice  = new AIManueverChoice();
	private static var MANUEVER_COMBO_SET:Int = 0;


	private static function checkManueverViability(manuever:String, availableCP:Int, tn:Int, threshold:Float, againstRoll:Int, againstTN:Int = 1, useAllCP:Bool=false):Int {
		var min:Int;
		var accum:Float;
		min =  useAllCP ? availableCP :    B_BS_REQUIRED > 1 ? B_BS_REQUIRED : 1;
		
		for (c in min...(availableCP+1)) {
			accum = TROSAI.getChanceToSucceedContest(c, tn, againstRoll, againstTN, B_BS_REQUIRED, true);
			if (accum >= threshold) {
				B_VIABLE_PROBABILITY = accum;
				return c;
			}
		}
		return 0;
	}
	

	private static function checkManueverViabilityBorderline(manuever:String, availableCP:Int, tn:Int, threshold:Float, againstRoll:Int, againstTN:Int = 1, useAllCP:Bool=false):Int {
		var min:Int;
		var accum:Float;
		var min:Int = useAllCP ? availableCP : 1;
		for (c in min...(availableCP + 1)) {
			var successProbabilitWith1BS =  TROSAI.getChanceToSucceedContest(c, tn, againstRoll, againstTN, 1, true);
			accum = (successProbabilitWith1BS +  TROSAI.getChanceToSucceedContest(c, tn, againstRoll, againstTN, 0) ) * 0.5;
			if (accum >= threshold) {
				B_VIABLE_PROBABILITY = successProbabilitWith1BS;
				return c;
			}
		}
		return 0;
	}
	
	@inspect("MANUEVER_CHOICE")
	public static function getRandomSuitableAttack(threshold:Float, availableCP:Int, againstRoll:Int = 0, againstTN:Int = 1, favorable:Bool=true, useAllCP:Bool=false):Bool {
		B_BS_REQUIRED = 1;  // default BS which may change later depending on manuever details
		var manuever:String = getRegularAttack(availableCP, 0, againstRoll, againstTN);
		if (manuever != null) {
			 availableCP -= getCostOfManuever(manuever);
			 var tn:Int = getATNOfManuever(manuever);
			var tarZone:Int  = getRegularTargetZone(tn, availableCP );
			if (tarZone != 0 ) {
				availableCP -= CURRENT_OPPONENT.body.getTargetZoneCost(tarZone);
				var cpToUse:Int = favorable ?  checkManueverViability(manuever, availableCP, tn, threshold, againstRoll, againstTN) : checkManueverViabilityBorderline(manuever, availableCP, getATNOfManuever(manuever), threshold, againstRoll, againstTN);
				if (cpToUse >= 0) {
					MANUEVER_CHOICE.setAttack(manuever, cpToUse, tn, tarZone, B_IS_OFFHAND);
					return true;
				}
			}
		}
		return false;
	}
	
	@inspect("MANUEVER_CHOICE")
	public static function getRandomSuitableDefense(threshold:Float, availableCP:Int, againstRoll:Int = 0, againstTN:Int = 1, mustRegainInitiative:Bool = false, favorable:Bool=true, useAllCP:Bool=false):Bool {
		B_BS_REQUIRED = 1;  // default BS which may change later depending on manuever details
		var manuever:String = getRegularDefense(availableCP, 0, mustRegainInitiative);
		if (manuever != null) {
			 availableCP -= getCostOfManuever(manuever);
			 var tn:Int =  getDTNOfManuever(manuever);
			var cpToUse:Int =   favorable ? checkManueverViability(manuever, availableCP, tn, threshold,  againstRoll, againstTN, useAllCP) : checkManueverViabilityBorderline(manuever, availableCP, getATNOfManuever(manuever), threshold, againstRoll, againstTN, useAllCP);
			if (cpToUse >= 0) {
				MANUEVER_CHOICE.setDefend(manuever, cpToUse, tn, B_IS_OFFHAND);
				return true;
			}
		}
		return false;
	}
	
	public static inline var FLAG_GET_CHEAPEST:Int = 1;
	public static inline var FLAG_USE_ALL_CP:Int = 2;

	@inspect("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static function getFavorableAttack(availableCP:Int, againstRoll:Int = 0, againstTN:Int=1, heuristic:Bool=true, flags:Int=0):Bool {
		var result:Bool  = heuristic ?  getRandomSuitableAttack(P_THRESHOLD_FAVORABLE, availableCP, againstRoll, againstTN, true, (flags & FLAG_USE_ALL_CP)!=0) : false;
		
		if (result) {
			B_VIABLE_PROBABILITY_GET = B_VIABLE_PROBABILITY;
			return true;		
		}
		// TODO: consider all possible combinations as last resort (exaustive search to get best probabilty ..)
		
		
		return false;
	}
	

	@inspect("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static function getFavorableDefense(availableCP:Int,  againstRoll:Int = 0,  againstTN:Int = 1, heuristic:Bool=true, flags:Int=0):Bool {
		
		var result:Bool = heuristic ? getRandomSuitableDefense(P_THRESHOLD_FAVORABLE,availableCP,  againstRoll, againstTN, false, true,  (flags & FLAG_USE_ALL_CP)!=0) : false;
		if (result) {
			B_VIABLE_PROBABILITY_GET = B_VIABLE_PROBABILITY;
			return true;		
		}
		
		// TODO:  consider all possible combinations as last resort (exaustive search to get best probabilty ..with/without cheapest cost )
		
		return false;
	}
	
	@inspect("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static function getBorderlineAttack(availableCP:Int, againstRoll:Int = 0,  againstTN:Int = 1, heuristic:Bool=true, flags:Int=0):Bool {
		
		var result:Bool  = heuristic ?   getRandomSuitableAttack(P_THRESHOLD_BORDERLINE, availableCP, againstRoll, againstTN, false) : false;
		if (result) {
			B_VIABLE_PROBABILITY_GET = B_VIABLE_PROBABILITY;
			return true;		
		}
		
		// consider all possible combinations as last resort (exaustive search to get best probabilty ..with/without cheapest cost)
		return false;
	}
	@inspect("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static function getBorderlineDefense(availableCP:Int, againstRoll:Int = 0,  againstTN:Int = 1, heuristic:Bool=true, flags:Int=0):Bool {
		
		var result:Bool  =  heuristic ?  getRandomSuitableDefense(P_THRESHOLD_BORDERLINE, availableCP, againstRoll, againstTN, false, false ) : false;
		if (result) {
			B_VIABLE_PROBABILITY_GET = B_VIABLE_PROBABILITY;
			return true;		
		}
		
		// consider all possible combinations as last resort (exaustive search to get best probabilty .. with/without cheapest cost)
		return false;
	}
	@inspect("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static function getBlockOpenAndStrike(availableCP:Int, againstCP:Int, againstRoll:Int = 0,  againstTN:Int = 1):Bool {
		
		return false;
	}
	@inspect("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static function getRotaOrCounter(availableCP:Int, againstCP:Int, againstRoll:Int=0,  againstTN:Int=1):Bool {
		return false;
	}
	@inspect("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static function getDisarm(availableCP:Int, againstCP:Int, againstRoll:Int=0,  againstTN:Int=1):Bool {
		return false;
	}
	@inspect("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static function getHook(availableCP:Int, againstCP:Int, againstRoll:Int=0,  againstTN:Int=1):Bool {
		return false;
	}
	@inspect("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static function getBeat(availableCP:Int, againstCP:Int, againstRoll:Int=0,  againstTN:Int=1):Bool {
		return false;
	}
	@inspect("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static function getBindStrike(availableCP:Int, againstCP:Int,  againstRoll:Int=0,  againstTN:Int=1):Bool {
		return false;
	}
	
	
	private function getPredictedDTN():Int {
		var weapon:Weapon;
		var dtn:Int = 7;
		
		weapon = (manueverUsingHands & Manuever.MANUEVER_HAND_MASTER) ==0 ? WeaponSheet.getWeaponByName(equipMasterhand) : null;
		if (weapon != null && weapon.dtn < dtn) {
			dtn = weapon.dtn;
		}
		
		weapon = (manueverUsingHands & Manuever.MANUEVER_HAND_SECONDARY) == 0 ? WeaponSheet.getWeaponByName(equipOffhand) : null;
		if (weapon != null && weapon.dtn < dtn) {
			dtn = weapon.dtn;
		}
		
		return dtn;
	}
	
	private function getComboExchangeBudgetingWithInitiative(combo:Int, cp:Int, cp2:Int, threatManuever:AIManueverChoice):Vector<Int> {
		if (combo > 0) {	
			switch( combo) {
				// ai combos typically with initiative:
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
			}
		}
		return null;
	}
	
	
	/**
	 * 
	 * @param	combo
	 * @param	cp
	 * @param	cp2
	 * @param	threatManuever
	 * @param	hasInitiative
	 * @param	secondExchange
	 * @return
	 */
	@inspect("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	private function getComboAction(combo:Int, cp:Int, cp2:Int, threatManuever:AIManueverChoice, hasInitiative:Bool = true, secondExchange:Bool = false):Bool {
		var flags:Int = secondExchange ? FLAG_USE_ALL_CP : 0;
		if (hasInitiative) {  // proceed with ideal combo after gaining initiative
			switch( combo) {
					// ai combos with initiative:
					// consider 2nd exchange...a disabling manuever, if regular damage attack not deemed favorable...
					case COMBO_PureMeanStrikes:	
						return  getFavorableAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(), true, flags) || getBorderlineAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags);
					case COMBO_HeavyFirstStrikes:
						return 
						!secondExchange ?   getFavorableAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags)
						: getFavorableAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags) ||  getBorderlineAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags);
					case COMBO_AlphaDisarm:	
						if (!secondExchange) {
							
						}
						else {
							return getFavorableAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags) || getBorderlineAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags);
						}
					case COMBO_AlphaHookStrike:
						if (!secondExchange) {
							
						}
						else {
								return getFavorableAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags) || getBorderlineAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags);
						}
					case COMBO_AlphaStrike:
						if (!secondExchange) {
							
						}
						else {
									return getFavorableAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags) || getBorderlineAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags);
						}
					case COMBO_BeatStrike:
						if (!secondExchange) {
							
						}
						else {
									return getFavorableAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags) || getBorderlineAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags);
						}
					case COMBO_BindAndStrike:
						if (!secondExchange) {
							
						}
						else {
									return getFavorableAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags) || getBorderlineAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags);
						}
					case COMBO_FeintStrike:
						if (!secondExchange) {
							
						}
						else {
									return getFavorableAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags) || getBorderlineAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags);
						}
					case COMBO_DoubleAttack:
						if (!secondExchange) {
							
						}
						else {
									return getFavorableAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags) || getBorderlineAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags);
						}
					case COMBO_SimulatenousBlockStrike:
						if (!secondExchange) {
							
						}
						else {
									return getFavorableAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags) || getBorderlineAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags);
						}
						
						
					// ai combos without initiative:  This branch should only happen on second exchange!
					case COMBO_DefensiveFirst:
								return getFavorableAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags) || getBorderlineAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags);
					case COMBO_AlphaInitiativeStealer:
								return getFavorableAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags) || getBorderlineAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags);
					case COMBO_AlphaDisarmDef:
								return getFavorableAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags) || getBorderlineAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags);
					case COMBO_SimulatenousBlockStrikeStealer:
								return getFavorableAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags) || getBorderlineAttack(cp, cp2, CURRENT_OPPONENT.getPredictedDTN(),  true, flags);
			}
		}
		else {
			switch( combo) {   // initiative lost or not available, may have to stick to not-so-ideal action for combo
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
					
					// ai combos without initiative: Whether 1st or second exchange, he'll continue to be onthe defensive!
					case COMBO_DefensiveFirst:
						// Determine which of these manuevers are to be used as overwritable viables
						//getFavorableDefense(cp, threatManuever.manueverCP, threatManuever., true, false);  // if secondExchange, make sure still having remaining dice dice for at least borderline attack  for 2nd exchange in order to be viable
						// getRotaOrCounter   //  is it viable/availalble? use it instead
						// getBlockOpenAndStrike //  is it viable/availalble? use it instead
						// if got any valids above, return true, else return false
						// if secondExchange, maybe can opt to go for borderline defense.....
					case COMBO_AlphaDisarmDef:
					
						
					case COMBO_AlphaInitiativeStealer:
					
					
					case COMBO_SimulatenousBlockStrikeStealer:  // if rules allow so under TROS TFOB stealing inintiatiive peanlty to be able to do this
					
						
			}
		}
		return false;
	}
	
	
	private static inline function addPossibleComboManueverChoice(index:Int):Void {
		MANUEVER_CHOICE.copyTo( index >= B_COMBO_CANDIDATE_MANUEVER.length ? (B_COMBO_CANDIDATE_MANUEVER[index] = new AIManueverChoice()) : B_COMBO_CANDIDATE_MANUEVER[index] );
	}
	
	
	
	/**
	 * 
	 * @param	cp
	 * @param	cp2
	 * @param	threatManuever
	 * @return
	 */
	@inspect("MANUEVER_COMBO_SET", "MANUEVER_CHOICE_SET")
	private function setBestComboActionWithInitiativePlan(cp:Int, cp2:Int, threatManuever:AIManueverChoice):Bool {
		
		B_COMBO_CANDIDATE_COUNT = 0;
		
		
		if ( CURRENT_OPPONENT.initiative)  {
			// considerations in a double-red situation..
			if (threatManuever != null && threatManuever.manueverType == AIManueverChoice.TYPE_ATTACKING  ) {
				// with known enemy attack manuever declared
			}
		}
		
		// consider all conventional combos for attacking with initiative
		// COMBO_PureMeanStrikes:	
		// COMBO_HeavyFirstStrikes:
		// COMBO_AlphaDisarm:
		// COMBO_AlphaHookStrike:
		// COMBO_AlphaStrike:
		// COMBO_BeatStrike:
		// COMBO_BindAndStrike:
		// COMBO_FeintStrike:
		// COMBO_DoubleAttack:
		// COMBO_SimulatenousBlockStrike:
		var i:Int = 1;
		var curProbability:Float = 0;
		var budget:Vector<Int>;
		var probabilityCheck:Float;
		var len:Int = COMBOS_LEN_INITIATIVE;
		while (i < COMBOS_LEN_INITIATIVE) {
			budget = getComboExchangeBudgetingWithInitiative(i, cp, cp2, threatManuever);
			if (budget != null) {
				if ( getComboAction(i, budget[BUDGET_EXCHANGE_1], budget[BUDGET_EXCHANGE_1_ENEMY], threatManuever, true, false) ) {
					probabilityCheck  = B_VIABLE_PROBABILITY_GET;
					if ( getComboAction(i, budget[BUDGET_EXCHANGE_2], budget[BUDGET_EXCHANGE_2_ENEMY], threatManuever, true, true)  &&  probabilityCheck > curProbability) {
						B_COMBO_CANDIDATES[B_COMBO_CANDIDATE_COUNT] = i;
						addPossibleComboManueverChoice(i);
						curProbability = probabilityCheck;
						B_COMBO_CANDIDATE_COUNT++;
					}
				}
			}
			i++;
		}
		
		if (B_COMBO_CANDIDATE_COUNT > 0) {
			var randIndex:Int = Std.int(Math.random() * B_COMBO_CANDIDATE_COUNT);
			MANUEVER_COMBO_SET = B_COMBO_CANDIDATES[randIndex];
			MANUEVER_CHOICE_SET = B_COMBO_CANDIDATE_MANUEVER[randIndex];
			return true;
		}
		

		return false;
	}
	
	/**
	 * 
	 * @param	cp
	 * @param	cp2
	 * @param	threatManuever
	 * @return
	 */
	@inspect("MANUEVER_COMBO_SET", "MANUEVER_CHOICE_SET")
	private function setBestComboActionWithoutInitiativePlan(cp:Int, cp2:Int, threatManuever:AIManueverChoice):Bool {
		
		B_COMBO_CANDIDATE_COUNT = 0;
		
		var i:Int = 1;
		var curProbability:Float = 0;
		var probabilityCheck:Float;
		var len:Int = COMBOS_LEN_NO_INITAITIVE;
		
		
		if (threatManuever == null || threatManuever.manueverType != AIManueverChoice.TYPE_ATTACKING) {
			// consider attacking without initiative...
		}
		
		// consider all conventional combos for defending without initiative or counter-attacking 
		// COMBO_DefensiveFirst:
		// COMBO_AlphaInitiativeStealer:
		// COMBO_AlphaDisarmDef:
		// COMBO_SimulatenousBlockStrikeStealer:
		
		// Collect viable combo actions for first exchange against threatManuever
		while ( i < len) {
			if ( getComboAction( -i, cp, cp2, threatManuever, false, false) ) {
				probabilityCheck  = B_VIABLE_PROBABILITY_GET;
				if ( probabilityCheck > curProbability) {
					B_COMBO_CANDIDATES[B_COMBO_CANDIDATE_COUNT] = -i;
					addPossibleComboManueverChoice(i);
					curProbability = probabilityCheck;
					B_COMBO_CANDIDATE_COUNT++;
				}
			}
			i++;
		}
		
		if (B_COMBO_CANDIDATE_COUNT > 0) {
			var randIndex:Int = Std.int(Math.random() * B_COMBO_CANDIDATE_COUNT);
			MANUEVER_COMBO_SET = B_COMBO_CANDIDATES[randIndex];
			MANUEVER_CHOICE_SET = B_COMBO_CANDIDATE_MANUEVER[randIndex];
			return true;
		}
		
		return false;
	}
	
	public function new() 
	{
		
	}

	
	// Standard public interface
	
	public function newExchange(newRound:Bool=false):Void {
		for (i in 0...decidedManuevers.length) {
			var d:AIManueverChoice = decidedManuevers[i];
			d.nothing();
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
	
	// step 1 setup
	public function preDeclareManuevers(target:TROSAiBot, targetedBy:Array<TROSAiBot>):Void {
		handsUsedUp = manueverUsingHands;
		
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
	
	// step 2 decide
	public function declareManuevers():Void {
		for (i in 0...opponentLen) {
			declareManueverAgainstOpponent(i);
		}
	}
	
	
	// -----
	
	
	// Main consideration against opponent
	
	public function declareManueverAgainstOpponent(index:Int):Bool {
		
		B_EQUIP = (handsUsedUp & Manuever.MANUEVER_HAND_MASTER) == 0 ? equipMasterhand : null;
		D_EQUIP = (handsUsedUp & Manuever.MANUEVER_HAND_SECONDARY) == 0 ?  equipOffhand : null;
		
		// Determine CP and threat from opponent
		
		var cpAvailable:Int = cpBudget[index];
		var cpAvailable2:Int;
		var opponent:TROSAiBot = opponents[index];
		CURRENT_OPPONENT = opponent;
		
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
				if ( setBestComboActionWithInitiativePlan(cp, opponent.cp, threatManuever) ) {
					plannedCombos[index] = MANUEVER_COMBO_SET; 
					MANUEVER_CHOICE_SET.copyTo(decidedManuevers[index]);
					return true;
				}
				
			}
			else {
				// decide on best combo without initaitive
				if ( setBestComboActionWithoutInitiativePlan(cp, opponent.cp, threatManuever) ) {
					plannedCombos[index] = MANUEVER_COMBO_SET; 
					MANUEVER_CHOICE_SET.copyTo(decidedManuevers[index]);
					return true;
				}
			}
		}
		else {		// assumed exchange 2
			// if got combo, use 2nd action for combo
			if ( plannedCombos[index] != 0 ) {
				if ( getComboAction( plannedCombos[index], cp, opponent.cp, threatManuever, initiative, true) ) {
					MANUEVER_CHOICE.copyTo(decidedManuevers[index]);
					decidedManuevers[index].manueverCP = cpAvailable;
					return true;
				}
			}
		}
		
		// use fallback action here
		
		return false;
	}
	
	
}