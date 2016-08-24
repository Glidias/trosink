package troshx.tros.ai;
import haxe.ds.Vector;
import haxe.ds.Vector;
import troshx.BodyChar;
import troshx.tros.Manuever;
import troshx.tros.ManueverSheet;
import troshx.tros.Weapon;
import troshx.tros.WeaponSheet;
import troshx.util.TROSAI;

/**
 * Basic AI Bot automation module for both human players and AI characters for The Riddle of Steel
 * @author Glidias
 */
@:expose
@:rtti
class TROSAiBot
{
	// Opponents that are targeting you...for choosing manuever 1,2,and 3 respectively
	private var opponents:Array<TROSAiBot> = [];
	private var opponentLen:Int = 0;
	private var cpBudget:Array<Int> = [];
	
	private var plannedCombos:Array<Int>  = [0, 0, 0, 0];
	
	private var currentExchange:Int = 0;
	
	// Character sheet ?
	@inject public var body:BodyChar;
	//@link public var armorValues::Dynamic<Float>
	@bind("_cp") public var cp:Int;
	@bind("_perception") public var perception:Int=4;
	@bind("_equipMasterhand") public var equipMasterhand:String;
	@bind("_equipOffhand") public var equipOffhand:String;
	@bind("_mobility") public var mobility:Int = 6;
	
	// Combat related
	@bind("_id") public var id:Int;
	@bind("_fight_initiative") public var initiative:Bool;
	@bind("_fight_stance") public var stance:Int;
	@bind("_manueverUsingHands") public var manueverUsingHands:Int = 0;

	private static var ENEMY_STEAL_COST:Int = 4;
	private static var MIN_EXPOSED_AV:Int = 0;
	private static inline function getTargetAlphaStrikeCPThreshold():Int {
		return ENEMY_STEAL_COST + 1 + MIN_EXPOSED_AV;
	}
	private static inline function setAlphaStrikeBudget(cp:Int, cp2:Int):Void {
		var minCP:Int = getTargetAlphaStrikeCPThreshold() - 1;
		minCP =cp2 > minCP ?  cp2 - minCP : 0;
		B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_1] = cp - minCP ;
		B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_2_ENEMY] = cp2;
		B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_2] = minCP;
		B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_2_ENEMY] = BUDGET_SKIP;
	}

	private var handsUsedUp:Int = 0;
	
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
	@inspect({min:0}) @bind public static var AVAIL_bash = 0; 
	@inspect({min:0}) @bind public static var AVAIL_spike = 0;  
	@inspect({min:0}) @bind public static var AVAIL_cut = 0;	
	@inspect({min:0}) @bind public static var AVAIL_thrust = 0;
	@inspect({min:0}) @bind public static var AVAIL_beat = 0;
	@inspect({min:0}) @bind public static var AVAIL_bindstrike = 0;
	@inspect({min:0}) @bind public static var AVAIL_hook = 0;

	// all recorded defend actoin availabilities  as  (cost - 1) for actual cost
	@inspect({min:0}) @bind public static var AVAIL_block = 0;
	@inspect({min:0}) @bind public static var AVAIL_parry = 0;
	@inspect({min:0}) @bind public static var AVAIL_duckweave = 0;
	@inspect({min:0}) @bind public static var AVAIL_partialevasion = 0;
	@inspect({min:0}) @bind public static var AVAIL_fullevasion = 0;
	@inspect({min:0}) @bind public static var AVAIL_blockopenstrike = 0;
	@inspect({min:0}) @bind public static var AVAIL_counter = 0;
	@inspect({min:0}) @bind public static var AVAIL_rota = 0;
	@inspect({min:0}) @bind public static var AVAIL_expulsion = 0;
	@inspect({min:0}) @bind public static var AVAIL_disarm = 0;
	@inspect({min:0}) @bind public static var AVAIL_StealInitiative = 0;
	
	private static function setTypicalAVAILCostsForTesting():Void {
		AVAIL_bash = 1;
		AVAIL_spike = 0;
		AVAIL_cut = 1;
		AVAIL_thrust = 1;
		AVAIL_beat = 1;
		AVAIL_bindstrike = 1;
		AVAIL_hook = 2;
		
		AVAIL_block = 1;
		AVAIL_parry = 1;
		AVAIL_duckweave = 1;
		AVAIL_partialevasion = 1;
		AVAIL_fullevasion = 1;
		AVAIL_blockopenstrike = 3;
		AVAIL_counter = 3;
		AVAIL_rota = 3;
		AVAIL_expulsion = 3;
		AVAIL_disarm = 2;
		AVAIL_StealInitiative = 5;
	}
	
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
			case "hook": return AVAIL_hook - 1; 

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
	
	
	
	@settable private static var B_EQUIP:String = "";  // master/offhand weapon  equip
	@settable private static var B_IS_OFFHAND:Bool = false;	// whether above is in offhand mode or not
	@settable private static var D_EQUIP:String = "";  // defensive offhand shield equip (if any)
	
	// mock budgets
	private static var B_COMBO_EXCHANGE_BUDGET:Vector<Int>  = new Vector<Int>(4);
	private static inline var BUDGET_EXCHANGE_1:Int = 0;
	private static inline var BUDGET_EXCHANGE_1_ENEMY:Int = 1;
	private static inline var BUDGET_EXCHANGE_2:Int = 2;
	private static inline var BUDGET_EXCHANGE_2_ENEMY:Int = 3;

	@inspect private static var WISH_TO_REGAIN_STANCE:Bool=false;
	@inspect private static var CURRENTLY_AGGROED:Bool=false;
	@inject private static var CURRENT_OPPONENT:TROSAiBot;
	// equipment, body link
	
	
	
	//private static inline var COMBO_None:Int = 0;
	// basic ai combos with initiative:
	private static inline var COMBO_PureMeanStrikes:Int = 1; // Pure Mean Strikes
	private static inline var COMBO_HeavyFirstStrikes:Int = 2; // Heavy-First Mean strikes
	private static inline var COMBO_AlphaDisarm:Int = 3; // Alpha Disarm
	private static inline var COMBO_AlphaHookStrike:Int = 4; // Alpha Hook Strike
	private static inline var COMBO_AlphaStrike:Int = 5; 	// Alpha Strike
	private static inline var COMBO_FeintStrike:Int = 6;  // Feint Strike
	private static inline var COMBO_DoubleAttack:Int = 7;  // Double Attack	
	private static inline var COMBO_SimulatenousBlockStrike:Int = 8;  // Simulatenous Block and Strike
	private static inline var COMBOS_LEN_INITIATIVE:Int = 9;
	private static inline var COMBO_CoupDeGrace:Int = 9;	// A killing blow attempt. If fully favorable, top priority.
	private static inline var COMBOS_LEN_INITIATIVE_FINAL:Int = 10;
	
	// basic ai combos without initiative
	private static inline var COMBO_DefensiveFirst:Int = -1;  // Defensive-first
	private static inline var COMBO_DefensiveBorderline:Int = -2;  // Defensive-borderline
	private static inline var COMBO_SpecialDefFirst:Int = -3;  // Defensive-borderline
	private static inline var COMBO_AlphaInitiativeStealer:Int = -4;  // Alpha Initiative Stealer
	private static inline var COMBO_AlphaDisarmDef:Int = -5;  // Alpha Disarm
	private static inline var COMBO_SimulatenousBlockStrikeStealer:Int = -6;  // Simultaneous Block-Strike Initiative Stealer 
	private static inline var COMBOS_LEN_NO_INITAITIVE:Int = 7;
	
	//public static var P_THRESHOLD_BEYOND_FAVORABLE:Float = 0.9;
	@inspect({min:0, max:1, display:"range", step:0.01}) public static var P_THRESHOLD_FAVORABLE:Float = 0.75;  // how willing is AI willing to gamble on a move for favorable success
	@inspect({min:0, max:1, display:"range", step:0.01}) public static var P_THRESHOLD_BORDERLINE:Float = 0.5;  // the favoring borderline between 2 parties, anything less poses too much disadvantaged risk to AI
	@inspect({min:0, max:1, display:"range", step:0.01}) public static var P_RECKLESS:Float = 0.2;  // less reckless will usually be at 0.15 instead of 0.2. least recklesss at 0.1
	
	//@inspect({min:0, max:1, display:"range", step:0.01}) 
	public static var P_THRESHOLD_ANTI_FAVORABLE:Float = 0.75;
		
	
	
	private static var B_CANDIDATES:Array<String> = [];
	private static var B_CANDIDATE_COUNT:Int = 0;
	private static var B_BS_REQUIRED:Int = 1; // required BS required in current context
	
	
	 private static var B_BS_REQUIRED_DEFAULT:Int = 1;
	 private static inline var COUP_BS_MODIFIER:Int = 1;  // todo: for testing temporarily until armor offset is included in
	@inspect({min:1}) private static var B_BS_REQUIRED_DMG_DEFAULT:Int = 1;  // set this to higher for AI that wishes to deal a heavier blow
	static private var PREFERED_HOOK_BS:Int = 2;  // set this to higher  for less risk attempt  , or lower for  more risk attempt (min 1)
	static private var PREFERED_DISARM_BS:Int=2;  // set this to higher  for less risk attempt , or lower for more risk attempt (min 1)
	static private var PREFERED_DISARM_DEF_BS:Int = 2;  // set this to higher  for less risk attempt , or lower for more risk attempt (min 1)
	@inspect static private var CAN_DESPERATE_ALPHASTRIKE:Bool = false;
	@inspect({display:"range", min:0, step:0.01, max:1}) static private var DESPERATE_ALPHASTRIKE_CHANCE:Float = 0.5;
	
	private static var B_VIABLE_PROBABILITY:Float;
	private static var B_VIABLE_PROBABILITY_GET:Float;
	private static var B_VIABLE_HEURISTIC:Bool;
	
	private static var B_MANUEVER_CHOICES:Array<AIManueverChoice> = [];
	private static var B_MANUEVER_CHOICE_PROBABILITIES:Array<Float> = [];
	private static var B_MANUEVER_CHOICE_COUNT:Int = 0;
	
	@enum("COMBO") private static var B_COMBO_CANDIDATES:Array<Int> = [];
	private static var B_COMBO_CANDIDATE_MANUEVER:Array<AIManueverChoice> = [];
	private static var B_COMBO_CANDIDATE_COUNT:Int = 0;
	
	private static inline var BPROB_BASE:Float = 1000;  
	private static inline var DMG_AGGR_BASE:Float = 10;
	private static inline var IMPOSSIBLE_TN:Int = 888;
	
	
	public static var B_USE_ADVANTAGE:Bool = false;

	@inspect([ { inspect:{min:0} }, { inspect:{min:0} }, { inspect:{min: -1} }, { inspect:{min:1}  } ]) 
	@return("B_USE_ADVANTAGE")
	/**
	 * Tries to heuristically choose "best" regular attack manuever for either damaging or advantage-based offenses (to gain CP advantage over opponent)
	 * @param	availableCP	Your available CP for use
	 * @param	roll	 (Optional) Indicates number of dice (likely) to roll. If left blank, uses entire availableCP.
	 * @param	againstRoll (Optional)  Indicates number of enemy dice (likely) to roll against.
	 * @param	againstTN (Optional)  Indicates (likely) enemy TN to roll against
	 * @return	The manuever id string
	 */
	public static function getRegularAttackOrAdvantageMove(availableCP:Int, roll:Int = 0,  againstRoll:Int = -1, againstTN:Int=1):String {
		// determine roughly which move is deemed "better"
		var str:String = getRegularAttack(availableCP, roll, againstRoll, againstTN);
		var curAggr:Float = -999;
		var regularStr:String = null;
		B_USE_ADVANTAGE = false;
		if (str != null) {
			curAggr = ATTACK_AGGR;
			regularStr = str;
		}
	
		str = getRegularAdvantageMove(availableCP, roll, againstRoll, againstTN);
		if (str != null && ATTACK_AGGR > curAggr) {
			curAggr = ATTACK_AGGR;
			B_USE_ADVANTAGE = true;
			return str;
		}
		return regularStr;
	}
	
	@return("B_CANDIDATES", "B_CANDIDATE_COUNT", "ATTACK_AGGR")
	@inspect([ { inspect:{min:0} }, { inspect:{min:0} }, { inspect:{min:-1} }, { inspect:{min:1}  } ]) 
	private static function getRegularAdvantageMove(availableCP:Int, roll:Int = 0,  againstRoll:Int = -1, againstTN:Int = 1):String {
		B_CANDIDATE_COUNT = 0;
		var weapon:Weapon = WeaponSheet.getWeaponByName(B_EQUIP);
		
		var tn:Int = weapon != null ? weapon.atn : IMPOSSIBLE_TN;
		var tn2:Int = weapon != null ?  weapon.atn2 : IMPOSSIBLE_TN;
		var cost:Int;
		var aggr:Float;
		
		if ( roll == 0) roll = availableCP;
		
		var tnP:Float = TROSAI.getTNSuccessProbForDie(tn);
		var tn2P:Float = TROSAI.getTNSuccessProbForDie(tn2);
		var gotEnemyRoll:Bool = againstRoll >= 0;
		
		//var probabilityToHitSlash:Float = gotEnemyRoll ? TROSAI.getChanceToSucceedContest(roll, tn, againstRoll, againstTN, 1) : 0;
		//var probabilityToHitThrust:Float =  againstRoll >= 0 ? TROSAI.getChanceToSucceedContest(roll, tn2, againstRoll, againstTN, 1) : 0;
	
		var aggrCur:Float = -999; 	// current rough aggregate considering TN, activation cost, and weapon damage in relation to dices being rolled

		if ( AVAIL_beat >0 && tn!= IMPOSSIBLE_TN) {
			
			cost = AVAIL_beat - 1;
			if (cost < availableCP) {   
				var tn:Int =  getATNOfManuever("beat");
				aggr = gotEnemyRoll ? Math.round(TROSAI.getChanceToSucceedContest(roll-cost,tn, againstRoll, againstTN, 1)*BPROB_BASE)  : tnP*(roll-cost) ;
				if (aggr > 0 && aggr >= aggrCur) {
					if (aggr != aggrCur) B_CANDIDATE_COUNT = 0;
					B_CANDIDATES[B_CANDIDATE_COUNT++] = "beat";
					aggrCur = aggr;
				}
			}
		}
		
		if ( AVAIL_bindstrike > 0) {
			cost = AVAIL_bindstrike - 1;
			 if (cost < availableCP) {
				aggr = gotEnemyRoll ?  Math.round(TROSAI.getChanceToSucceedContest(roll-cost, getATNOfManuever("bindstrike"), againstRoll, againstTN, 1)*BPROB_BASE) : Math.min(tnP,tn2P)*(roll-cost);
				if (aggr > 0 && aggr > aggrCur ) {
					//if (aggr != aggrCur) B_CANDIDATE_COUNT = 0;
					B_CANDIDATES[B_CANDIDATE_COUNT++] = "bindstrike";
					aggrCur = aggr;
					
				}
			}
		}
		
		
		if (B_CANDIDATE_COUNT == 0) return null;
		
		ATTACK_AGGR = aggrCur;
		
		return B_CANDIDATES[Std.int(Math.random()*B_CANDIDATE_COUNT)];
	}
	
	private static inline function mathMax(a:Int, b:Int):Int {
		return a >= b ? a : b;
	}
	
	private static function enforceDmgAggrIfFav(val:Float):Float {
		return Math.round(val * BPROB_BASE) +  (val >= P_THRESHOLD_FAVORABLE ?  BPROB_BASE : 0);
	}
	
	
	private static var ATTACK_AGGR:Float = 0;
	/**
	 * Tries to heuristically choose "best" regular attack manuever for damaging enemy
	 * @param	availableCP	Your available CP for use
	 * @param	roll	 (Optional) Indicates number of dice (likely) to roll. If left blank, uses entire availableCP.
	 * @param	againstRoll (Optional)  Indicates number of enemy dice (likely) to roll against.
	 * @param	againstTN (Optional)  Indicates (likely) enemy TN to roll against
	 * @return	The manuever id string
	 */
	@return("B_CANDIDATES", "B_CANDIDATE_COUNT", "ATTACK_AGGR")
	@inspect([ { inspect:{min:0} }, { inspect:{min:0} }, { inspect:{min:-1} }, { inspect:{min:1}  } ]) 
	private static function getRegularAttack(availableCP:Int, roll:Int = 0,  againstRoll:Int = -1, againstTN:Int=1):String {
	
		B_CANDIDATE_COUNT = 0;
		var weapon:Weapon = WeaponSheet.getWeaponByName(B_EQUIP);
		
		var tn:Int = weapon != null ? weapon.atn : IMPOSSIBLE_TN;
		var tn2:Int = weapon != null ?  weapon.atn2 : IMPOSSIBLE_TN;
		var cost:Int;
		var aggr:Float;
		
		if ( roll == 0) roll = availableCP;
		
		var tnP:Float = TROSAI.getTNSuccessProbForDie(tn);
		var tn2P:Float = TROSAI.getTNSuccessProbForDie(tn2);
		
		var gotEnemyRoll:Bool = againstRoll >= 0;
		
		var concessionDmg:Bool = B_BS_REQUIRED_DMG_DEFAULT > 1;
		
		var dmg:Int = weapon != null && gotEnemyRoll ? weapon.damage : 0;
		var dmgT:Int = weapon != null &&  gotEnemyRoll ? weapon.damage2 : 0;
		//var probabilityToHitSlash:Float =  gotEnemyRoll ? TROSAI.getChanceToSucceedContest(roll, tn, againstRoll, againstTN, B_BS_REQUIRED_DMG_DEFAULT) : 0;
		//var probabilityToHitThrust:Float =  gotEnemyRoll ? TROSAI.getChanceToSucceedContest(roll, tn2, againstRoll, againstTN,  B_BS_REQUIRED_DMG_DEFAULT) : 0;
		
		var aggrCur:Float = -999; 	// current rough aggregate considering TN, activation cost, and weapon damage in relation to dices being rolled

		if ( AVAIL_bash >0 && tn!= IMPOSSIBLE_TN) {
			
			cost = AVAIL_bash - 1;
			if (cost < availableCP) {
				aggr = gotEnemyRoll ? enforceDmgAggrIfFav(TROSAI.getChanceToSucceedContest(roll-cost, tn, againstRoll, againstTN, B_BS_REQUIRED_DMG_DEFAULT , true)) + (dmg/DMG_AGGR_BASE)  : tnP*(roll-cost);
				if (aggr > 0 && aggr >= aggrCur) {
					if (aggr != aggrCur) B_CANDIDATE_COUNT = 0;
					B_CANDIDATES[B_CANDIDATE_COUNT++] = "bash";
					aggrCur = aggr;
				}

			}
		}
		if ( AVAIL_cut > 0 && tn!= IMPOSSIBLE_TN) {
			cost = AVAIL_cut - 1;
			 if (cost < availableCP) {
				aggr = gotEnemyRoll ? enforceDmgAggrIfFav( TROSAI.getChanceToSucceedContest(roll-cost, tn, againstRoll, againstTN, B_BS_REQUIRED_DMG_DEFAULT, true))+ (dmg/DMG_AGGR_BASE)  : tnP*(roll-cost);
				if ( aggr > 0 && aggr >= aggrCur ) {
					if (aggr != aggrCur) B_CANDIDATE_COUNT = 0;
					B_CANDIDATES[B_CANDIDATE_COUNT++] = "cut";
					aggrCur = aggr;
					
				}
			
			
			}
		}
		if ( AVAIL_spike > 0 && tn2!= IMPOSSIBLE_TN) { 
			cost = AVAIL_spike - 1;
			if (cost < availableCP) {
				aggr = gotEnemyRoll ? enforceDmgAggrIfFav( TROSAI.getChanceToSucceedContest(roll-cost, tn2, againstRoll, againstTN,B_BS_REQUIRED_DMG_DEFAULT, true))+ (dmgT/DMG_AGGR_BASE) : tn2P*(roll-cost);
				if ( aggr > 0 && aggr >= aggrCur ) {
						if (aggr != aggrCur) B_CANDIDATE_COUNT = 0;
						B_CANDIDATES[B_CANDIDATE_COUNT++] = "spike";
						aggrCur = aggr;
						
				}
				
			}
		}
		
		if ( AVAIL_thrust > 0 && tn2!= IMPOSSIBLE_TN) {
			cost = AVAIL_thrust - 1;
			if (cost < availableCP) {
				aggr = gotEnemyRoll ? enforceDmgAggrIfFav( TROSAI.getChanceToSucceedContest(roll-cost, tn2, againstRoll, againstTN, B_BS_REQUIRED_DMG_DEFAULT, true))+ (dmgT/DMG_AGGR_BASE)  : tn2P*(roll-cost);
				
				if (aggr > 0 && aggr >= aggrCur ) {
					if (aggr != aggrCur) B_CANDIDATE_COUNT = 0;
					B_CANDIDATES[B_CANDIDATE_COUNT++] = "thrust";
					aggrCur = aggr;
					
				}
				
			}
		}
		
		
		
		
		if (B_CANDIDATE_COUNT == 0) return null;
		
		ATTACK_AGGR = aggrCur;
		
		return B_CANDIDATES[Std.int(Math.random()*B_CANDIDATE_COUNT)];
	}
	

	
	
	
	/**
	 * Tries to heuristically choose "best" regular defense manuever
	 * @param	availableCP	 Your available CP for use
	 * @param	roll (Optional) Indicates number of dice (likely) to roll. If left blank, uses entire availableCP.
	 * @param   enforceMustRegainInitiative  (Optional) If set to true, defensive manuevers that have no means of regaining back initiative would be omitted. 
	 * @return	The manuever id string
	 */
	@return("B_CANDIDATES", "B_CANDIDATE_COUNT")
	@inspect([ { inspect:{min:0} }, { inspect:{min:0} } ]) 
	public static function getRegularDefense(availableCP:Int, roll:Int = 0, enforceMustRegainInitiative:Bool=false):String {
		
		B_CANDIDATE_COUNT = 0;
			
		var weapon:Weapon = WeaponSheet.getWeaponByName(B_EQUIP);
		var offhand:Weapon = WeaponSheet.getWeaponByName(D_EQUIP);
		
		var tn:Int = weapon != null ? weapon.dtn : IMPOSSIBLE_TN;
		var tnOff:Int = offhand != null ? offhand.dtn : IMPOSSIBLE_TN;
		var tnP:Float = TROSAI.getTNSuccessProbForDie(tn);
		var tnPOff:Float = TROSAI.getTNSuccessProbForDie(tnOff);
			
		var aggr:Float; 
		var aggrCur:Float = -999; 	// current rough aggregate considering TN, activation cost, in relation to dices being rolled
		
		
		if ( roll == 0) roll = availableCP;
		
		var cost:Int;
		
		
		if (AVAIL_block > 0 && tnPOff!=IMPOSSIBLE_TN) {
			cost = AVAIL_block - 1;
			if (cost < roll) {
				aggr = tnPOff * (roll - cost);
				if (aggr >= aggrCur) {
					if (aggr != aggrCur) B_CANDIDATE_COUNT = 0;
					B_CANDIDATES[B_CANDIDATE_COUNT++] = "block";
					aggrCur = aggr;
				}
			}
		}
		
		if (AVAIL_parry > 0 && tnP != IMPOSSIBLE_TN) {
			cost = AVAIL_parry - 1;
			if (cost < availableCP) {
				aggr = tnP * (roll - cost);
				if (aggr >= aggrCur) {
					if (aggr != aggrCur) B_CANDIDATE_COUNT = 0;
					B_CANDIDATES[B_CANDIDATE_COUNT++] = "parry";
					aggrCur = aggr;
				}
			}
		}
		
		if (AVAIL_partialevasion > 0 ) { 
			cost = AVAIL_partialevasion - 1;
			if (cost  + (enforceMustRegainInitiative ? 2 : 0) < availableCP) {
				aggr = TROSAI.getTNSuccessProbForDie(7) * (roll - cost  -.00000001);
				if (aggr >= aggrCur) {
					if (aggr != aggrCur) B_CANDIDATE_COUNT = 0;
					B_CANDIDATES[B_CANDIDATE_COUNT++] = "partialevasion";
					aggrCur = aggr;
				}
			}
		}
		
		if (B_CANDIDATE_COUNT == 0) return null;
		
		return B_CANDIDATES[Std.int(Math.random()*B_CANDIDATE_COUNT)];
	}
	
	// considerTODO: this should be factored out into ManuverSheet method
	private static function getATNOfManuever(manuever:String):Int {
		var weapon:Weapon = WeaponSheet.getWeaponByName(B_EQUIP);
		var weaponOff:Weapon = B_IS_OFFHAND ? weapon : WeaponSheet.getWeaponByName(D_EQUIP);
		var tn:Int = weapon != null ? weapon.atn : IMPOSSIBLE_TN;
		var tn2:Int = weapon != null ?  weapon.atn2 : IMPOSSIBLE_TN;
		var tnOff:Int = weaponOff != null ? weaponOff.shield ? weaponOff.dtn :  weaponOff.atn : IMPOSSIBLE_TN;
		var cost:Int;
		var aggr:Float;
	
		switch(manuever) {
			case "bash": return tn;
			case "beat": return tn;
			case "cut": return tn;
			case "disarm": return tn;
			case "hook": return (weapon != null ? weapon.getHookingATN() : IMPOSSIBLE_TN);
			case "bindstrike": return tnOff;
			case "spike": return tn2;
			case "thrust": return tn2;
		}
		return 0;
	}
	private static inline function isFleeingManuever(manueverName:String):Bool {
		return manueverName == "fullevasion";
	}
	
	private static function getDTNOfManuever(manuever:String):Int {
		var weapon:Weapon = WeaponSheet.getWeaponByName(B_EQUIP);
		var offhand:Weapon = WeaponSheet.getWeaponByName(D_EQUIP);
		
		var tn:Int = weapon != null ? weapon.dtn : IMPOSSIBLE_TN;
		var tnOff:Int = offhand != null ? offhand.dtn : IMPOSSIBLE_TN;
		
		switch(manuever) {
			case "block": return tnOff;
			case "parry": return tn;
			case "rota": return tn;
			case "counter": return tn;
			case "disarm": return tn;
			case "blockopenstrike": return tn; 
			case "expulsion": return tn; 
			case "partialevasion": return 7;
			case "duckweave": return 9;
			case "fullevasion": return FLEE_TN;
		}	
		return 0;
	}
	
	
	
	private static function getFollowupAtkManuever(favorable:Bool, lastManuever:AIManueverChoice, availableCPWithBonus:Int, againstCP:Int, customThreshold:Float = 0):Bool {
		var threshold:Float = customThreshold != 0 ? customThreshold : favorable ? P_THRESHOLD_FAVORABLE : P_THRESHOLD_BORDERLINE;
		// todo:  followup on necessary counterattack manuever
		
		
		return false;
	}
	
	// todo: factor in weapon damage
	public static function getTargetZoneAverageAVOffset(tarZone:Int, weaponName:String):Int {
		// TODO: consider armor and the like
		return 0;
	}
	
	public static function getRegularTargetZone(manuever:String, atn:Int, cp:Int):Int {
		// TODO: proper pick for manuever
		
		var zones = CURRENT_OPPONENT.body.zones; 
		var randIndex:Int = 1 + Std.int( Math.random() * (zones.length - 1) );
		
		return randIndex;
		
		
		// TODO: consider armor and the like
		/*
		for (i in 1...zones.length) {
			
		}
		
		
		return 0;
		*/
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
	private static var MANUEVER_CHOICE_1:AIManueverChoice  = new AIManueverChoice();
	private static var MANUEVER_CHOICE_SET:AIManueverChoice  = new AIManueverChoice();
	@enum("COMBO") private static var MANUEVER_COMBO_SET:Int = 0;

	@return("B_VIABLE_PROBABILITY")
	private static function checkCostViability(availableCP:Int, tn:Int, threshold:Float, againstRoll:Int, againstTN:Int = 1, useAllCP:Bool=false):Int {
		var min:Int;
		var accum:Float;
		min =  useAllCP ? availableCP :    B_BS_REQUIRED > 1 ? B_BS_REQUIRED : 1;
		
		for (c in min...(availableCP+1)) {
			accum = precisionPerc( TROSAI.getChanceToSucceedContest(c, tn, againstRoll, againstTN, B_BS_REQUIRED, true) );
			if (accum >= threshold) {
				B_VIABLE_PROBABILITY = accum;// B_BS_REQUIRED == 1 ? accum :  TROSAI.getChanceToSucceedContest(c, tn, againstRoll, againstTN, 1, true);
				return c;
			}
		}
		return 0;
	}
	
	private static function checkCostViabilityWithBs(availableCP:Int, tn:Int, threshold:Float, againstRoll:Int, againstTN:Int = 1, useAllCP:Bool = false, bs:Int=1):Int {
		var lastBS:Int = B_BS_REQUIRED;
		B_BS_REQUIRED = bs;
		var result:Int = checkCostViability(availableCP, tn, threshold, againstRoll, againstTN, useAllCP);
		B_BS_REQUIRED = lastBS;
		return result;
	}
	
	private static inline function precisionPerc(val:Float):Float {
		return Math.round(val / 0.01) * 0.01;
	}
	
	@return("B_VIABLE_PROBABILITY")
	private static function checkCostViabilityBorderline( availableCP:Int, tn:Int, threshold:Float, againstRoll:Int, againstTN:Int = 1, useAllCP:Bool=false):Int {
		var min:Int;
		var accum:Float;
		var bsRequired:Int = B_BS_REQUIRED > 1 ? B_BS_REQUIRED : 1;
		var min:Int =  useAllCP ? availableCP :   bsRequired;
		
		for (c in min...(availableCP + 1)) {
			var successProbabilitWithBS =  TROSAI.getChanceToSucceedContest(c, tn, againstRoll, againstTN, bsRequired, true);
			accum = precisionPerc ( (successProbabilitWithBS +  TROSAI.getChanceToSucceedContest(c, tn, againstRoll, againstTN, bsRequired-1, false) ) * 0.5 );
			
			if (accum >= threshold) {
				if (successProbabilitWithBS == 0) return 0;
				B_VIABLE_PROBABILITY = successProbabilitWithBS;
				return useAllCP ? availableCP : c;
			}
		}
		return 0;
	}
	
	
	
	@return("B_VIABLE_PROBABILITY_GET")
	//@inspect([ { inspect:{min:0} }, { inspect:{min:0} }, { inspect:{min:0, max:1, value:0.75, display:"range", step:0.01} }, { inspect:{min:0} }, {inspect:null}, { inspect:{min:1} }  ]) 
	private static function checkCostAntiFavorability( availableCP:Int, tn:Int, threshold:Float, againstCP:Int, againstTN:Int = 1, useAllCP:Bool=false, offset:Int=0, requiredBS:Int=1):Int {
		var min:Int;
		var accum:Float;
		
		min =  1;
		var cpToUse:Int = 0;
	
		for (c in min...(availableCP+1)) {
			accum = precisionPerc( TROSAI.getChanceToSucceedContest(againstCP, againstTN, c, tn, requiredBS, true) );
				
			if (accum < threshold) {
				cpToUse = c;
				break;
			}
		}
		
		if (cpToUse != 0) {
			if (useAllCP) {
				cpToUse = availableCP;
			}
			else {
				cpToUse += offset;
				if (cpToUse <= 0 ) cpToUse = 1;
				if (cpToUse > availableCP) cpToUse = availableCP;
			}
			
			B_VIABLE_PROBABILITY_GET = TROSAI.getChanceToSucceedContest(cpToUse, tn, againstCP, againstTN, B_BS_REQUIRED, true);
		
		}
		
		
		
		
		return cpToUse;
	}
	
	
	@return("B_VIABLE_PROBABILITY_GET")
	//@inspect([ { inspect:{min:0} }, { inspect:{min:0} }, { inspect:{min:0, max:1, value:0.5, display:"range", step:0.01} }, { inspect:{min:0} }, {inspect:null}, { inspect:{min:1} }  ]) 
	private static function checkCostAntiBorderline(availableCP:Int, tn:Int, threshold:Float, againstCP:Int, againstTN:Int = 1, useAllCP:Bool=false, offset:Int=0):Int {
		var min:Int;
		var accum:Float;
		min =  1;
		var cpToUse:Int = 0;
		var successProbabilitWith1BS = .0;
		
		for (c in min...(availableCP+1)) {
			successProbabilitWith1BS =  TROSAI.getChanceToSucceedContest(againstCP, againstTN, c, tn, 1, true);
			accum = precisionPerc(  (successProbabilitWith1BS +  TROSAI.getChanceToSucceedContest(againstCP, againstTN, c, tn, 0) ) * 0.5 );
			if (accum < threshold) {
				cpToUse = c;
				break;
			}
		}
		
		if (cpToUse != 0) {
			if (useAllCP) {
				cpToUse = availableCP;
			}
			else {
				cpToUse += offset;
				if (cpToUse <= 0 ) cpToUse = 1;
				if (cpToUse > availableCP) cpToUse = availableCP;
			}
			
			B_VIABLE_PROBABILITY_GET = TROSAI.getChanceToSucceedContest(cpToUse, tn, againstCP, againstTN, B_BS_REQUIRED, true);
		}
		return cpToUse;
	}
	
	
	

	private static inline function getCostOfAvail(avail:Int):Int {
		return avail - 1;
	}
	
	private static function getTheSuitableAttack(manuever:String, tn:Int, tarZone:Int, threshold:Float, availableCP:Int, againstRoll:Int = 0, againstTN:Int = 1, favorable:Bool = true, useAllCP:Bool = false):Bool {
		var cpToUse:Int = favorable ?  checkCostViability( availableCP, tn, threshold, againstRoll, againstTN, useAllCP) : checkCostViabilityBorderline( availableCP, tn, threshold, againstRoll, againstTN, useAllCP);
		if (cpToUse > 0) {
			MANUEVER_CHOICE.setAttack(manuever, cpToUse, tn, tarZone, getCostOfManuever(manuever), B_IS_OFFHAND);
			return true;
		}
		return false;
	}

	
	private static function getTheSuitableDefense(manuever:String, tn:Int,  threshold:Float, availableCP:Int, againstRoll:Int = 0, againstTN:Int = 1, favorable:Bool = true, useAllCP:Bool = false):Bool {
		var cpToUse:Int =   favorable ? checkCostViability( availableCP, tn, threshold,  againstRoll, againstTN, useAllCP) : checkCostViabilityBorderline( availableCP, tn, threshold, againstRoll, againstTN, useAllCP);
		if (cpToUse > 0) {
			MANUEVER_CHOICE.setDefend(manuever, cpToUse, tn, getCostOfManuever(manuever), B_IS_OFFHAND);
			return true;
		}
		return false;
	}
	
	private static function getTheForcefulInitiativeAttack(manuever:String, tn:Int, tarZone:Int, threshold:Float, availableCP:Int, againstCP:Int = 0, againstTN:Int = 1, favorable:Bool=true, useAllCP:Bool=false, offset:Int=0):Bool {
		var cpToUse:Int = favorable ?  checkCostAntiFavorability( availableCP, tn, threshold, againstCP, againstTN, useAllCP, offset) : checkCostAntiBorderline( availableCP, tn, threshold, againstCP, againstTN, useAllCP, offset);
		if (cpToUse > 0) {
			MANUEVER_CHOICE.setAttack(manuever, cpToUse, tn, tarZone,  getCostOfManuever(manuever), B_IS_OFFHAND);
			return true;
		}
		return false;
	}
	
	@return("MANUEVER_CHOICE", "B_VIABLE_PROBABILITY")
	@inspect([ { inspect:{min:0,step:0.01, max:1, display:"range"} }, { inspect:{min:0} }, { inspect:{min:0} }, { inspect:{min:1}  } ]) 
	public static function getASuitableAttack(threshold:Float, availableCP:Int, againstRoll:Int = 0, againstTN:Int = 1, favorable:Bool=true, useAllCP:Bool=false):Bool {
		B_BS_REQUIRED = B_BS_REQUIRED_DMG_DEFAULT;  // default BS which may change later depending on manuever details
		
		var manuever:String =getRegularAttack(availableCP, 0, againstRoll, againstTN);
		if (manuever != null) {
			 availableCP -= getCostOfManuever(manuever);
			 var tn:Int = getATNOfManuever(manuever);
			var tarZone:Int  = getRegularTargetZone(manuever, tn, availableCP );
			if (tarZone != 0 ) {
				availableCP -= CURRENT_OPPONENT.body.getTargetZoneCost(tarZone);
				return getTheSuitableAttack(manuever, tn, tarZone, threshold, availableCP, againstRoll, againstTN, favorable, useAllCP);
			}
		}
		return false;
	}
	
	@return("MANUEVER_CHOICE", "B_VIABLE_PROBABILITY_GET")
	@inspect([ { inspect:{min:0,step:0.01, max:1, display:"range"} }, { inspect:{min:0} }, { inspect:{min:0} }, { inspect:{min:1}  } ]) 
	public static function getAForcefulInitiativeAttack(threshold:Float, availableCP:Int, againstCP:Int = 0, againstTN:Int = 1, favorable:Bool=true, useAllCP:Bool=false, offset:Int=0):Bool {
		
		var manuever:String = getRegularAttackOrAdvantageMove(availableCP, 0, againstCP, againstTN);
		B_BS_REQUIRED = B_USE_ADVANTAGE ? 1 : B_BS_REQUIRED_DMG_DEFAULT;  // default BS which may change later depending on manuever details
		if (manuever != null) {
			 availableCP -= getCostOfManuever(manuever);
			 var tn:Int = getATNOfManuever(manuever);
			 var tarZone:Int  = getRegularTargetZone(manuever, tn, availableCP );
			if (tarZone != 0 ) {
				var result:Bool  =  getTheForcefulInitiativeAttack(manuever, tn, tarZone, threshold, availableCP, againstCP, againstTN, favorable, useAllCP, offset);
				if (result) return true;
			}
		}
		return false;
	}
	
	
	
	@return("MANUEVER_CHOICE", "B_VIABLE_PROBABILITY")
	@inspect([ { inspect:{min:0,step:0.01, max:1, display:"range"} }, { inspect:{min:0} }, { inspect:{min:0} }, { inspect:{min:1}  } ]) 
	public static function getASuitableDefense(threshold:Float, availableCP:Int, againstRoll:Int = 0, againstTN:Int = 1, mustRegainInitiative:Bool = false, favorable:Bool=true, useAllCP:Bool=false):Bool {
		B_BS_REQUIRED = B_BS_REQUIRED_DEFAULT;  // default BS which may change later depending on manuever details
		var manuever:String = getRegularDefense(availableCP, 0, mustRegainInitiative);
		if (manuever != null) {
			 availableCP -= getCostOfManuever(manuever);
			 var tn:Int =  getDTNOfManuever(manuever);
			return getTheSuitableDefense(manuever, tn, threshold, availableCP, againstRoll, againstTN, favorable, useAllCP);
		}
		return false;
	}
	
	public static inline var FLAG_GET_CHEAPEST:Int = 1;
	public static inline var FLAG_USE_ALL_CP:Int = 2;
	public static inline var FLAG_BORDERLINE_DEF_SAFETY:Int = 4;
	
	static public inline var FLEE_TN:Int = 4;

	@inspect([ { inspect:{min:0} }, { inspect:{min:0} }, { inspect:{min:1} }, { inspect:null  }, { inspect:null, bitmask:"FLAG" },  { inspect:{min:0, display:"range", step:0.01, max:1} } ]) 
	@return("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE", "B_VIABLE_HEURISTIC")
	public static inline function getFavorableAttack(availableCP:Int, againstRoll:Int = 0, againstTN:Int = 1, heuristic:Bool = true, flags:Int = 0, customThreshold:Float=0):Bool {
		return getFBAttack(true, availableCP, againstRoll, againstTN, heuristic, flags, customThreshold);
	}
	

	
	@inspect([ { inspect:{min:0} }, { inspect:{min:0} }, { inspect:{min:1} }, { inspect:null  }, { inspect:null, bitmask:"FLAG" },  { inspect:{min:0, display:"range", step:0.01, max:1}} ]) 
	@return("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE", "B_VIABLE_HEURISTIC")
	public static function getBorderlineAttack(availableCP:Int, againstRoll:Int = 0,  againstTN:Int = 1, heuristic:Bool=true, flags:Int=0, customThreshold:Float=0):Bool {
		return getFBAttack(false, availableCP, againstRoll, againstTN, heuristic, flags, customThreshold);
	}
	
	
	private static function getFBAttack(favorable:Bool, availableCP:Int, againstRoll:Int = 0, againstTN:Int = 1, heuristic:Bool = true, flags:Int = 0, customThreshold:Float=0):Bool {
		var threshold:Float = customThreshold!= 0 ? customThreshold : favorable ? P_THRESHOLD_FAVORABLE : P_THRESHOLD_BORDERLINE;
		B_VIABLE_HEURISTIC = false;
		var result:Bool  = heuristic ?  getASuitableAttack(threshold, availableCP, againstRoll, againstTN, favorable, (flags & FLAG_USE_ALL_CP)!=0) : false;
		if (result) {
			B_VIABLE_PROBABILITY_GET = B_VIABLE_PROBABILITY;
			B_VIABLE_HEURISTIC = true;
			return true;		
		}
		
		//  consider all possible combinations as last resort (exaustive search to get best probabilty .., with/without cheapest cost)
		var cp:Int = availableCP;
		var cpToUse:Int;
		var useCheapestMult:Int = (flags & FLAG_GET_CHEAPEST) != 0 ? 1 : 0;
		var aggr:Float;	
		B_MANUEVER_CHOICE_COUNT = 0;
		
		var curAggr:Float = 9999999999999;
		var tn:Int;
		var checkCostFunc:Int->Int->Float->Int->Int->Bool->Int = favorable ? checkCostViability : checkCostViabilityBorderline;
		
		if (AVAIL_bash > 0) {
			B_BS_REQUIRED = B_BS_REQUIRED_DMG_DEFAULT;
			cp  = availableCP - getCostOfAvail(AVAIL_bash);
			if ( cp > 0 ) {
				tn = getATNOfManuever("bash");
				for (i in 1...CURRENT_OPPONENT.body.thrustStartIndex) {
					B_BS_REQUIRED += getTargetZoneAverageAVOffset(i, B_EQUIP);
					cpToUse  = checkCostFunc(cp, tn, threshold, againstRoll, againstTN, (flags & FLAG_USE_ALL_CP) != 0 );
					if (cpToUse > 0) {
						aggr = useCheapestMult*cpToUse +  (1 - B_VIABLE_PROBABILITY);
						if (aggr <= curAggr) {
							if (aggr != curAggr) B_MANUEVER_CHOICE_COUNT = 0;
							MANUEVER_CHOICE.setAttack("bash", cpToUse, tn, i, getCostOfAVAIL(AVAIL_bash),  B_IS_OFFHAND);
							addPossibleRegularManueverChoice(B_MANUEVER_CHOICE_COUNT);
							B_MANUEVER_CHOICE_PROBABILITIES[B_MANUEVER_CHOICE_COUNT] = B_VIABLE_PROBABILITY;
							B_MANUEVER_CHOICE_COUNT++;
							curAggr = aggr;
						}
					}
					
				}
			}	
		}
		if (AVAIL_spike > 0) {
			B_BS_REQUIRED = B_BS_REQUIRED_DMG_DEFAULT;
			cp  = availableCP - getCostOfAvail(AVAIL_spike);
			if ( cp > 0 ) {
				tn = getATNOfManuever("spike");
				for (i in CURRENT_OPPONENT.body.thrustStartIndex...CURRENT_OPPONENT.body.zones.length) {
					B_BS_REQUIRED += getTargetZoneAverageAVOffset(i, B_EQUIP);
					cpToUse  = checkCostFunc(cp, tn, threshold, againstRoll, againstTN, (flags & FLAG_USE_ALL_CP) != 0 );
					if (cpToUse > 0) {
						aggr = useCheapestMult*cpToUse +  (1 - B_VIABLE_PROBABILITY);
						if (aggr <= curAggr) {
							if (aggr != curAggr) B_MANUEVER_CHOICE_COUNT = 0;
							MANUEVER_CHOICE.setAttack("spike", cpToUse, tn, i, getCostOfAVAIL(AVAIL_spike), B_IS_OFFHAND);
							addPossibleRegularManueverChoice(B_MANUEVER_CHOICE_COUNT);
							B_MANUEVER_CHOICE_PROBABILITIES[B_MANUEVER_CHOICE_COUNT] = B_VIABLE_PROBABILITY;
							B_MANUEVER_CHOICE_COUNT++;
							curAggr = aggr;
						}
					}
				}
			}
		}
		if (AVAIL_cut > 0) {
			B_BS_REQUIRED = B_BS_REQUIRED_DMG_DEFAULT;
			cp  = availableCP - getCostOfAvail(AVAIL_cut);
			if ( cp > 0 ) {
				tn = getATNOfManuever("cut");
				for (i in 1...CURRENT_OPPONENT.body.thrustStartIndex) {
					B_BS_REQUIRED += getTargetZoneAverageAVOffset(i, B_EQUIP);
					cpToUse  = checkCostFunc(cp, tn, threshold, againstRoll, againstTN, (flags & FLAG_USE_ALL_CP) != 0 );
					if (cpToUse > 0) {
						aggr = useCheapestMult*cpToUse +  (1 - B_VIABLE_PROBABILITY);
						if (aggr <= curAggr) {
							if (aggr != curAggr) B_MANUEVER_CHOICE_COUNT = 0;
							MANUEVER_CHOICE.setAttack("cut", cpToUse, tn, i, getCostOfAVAIL(AVAIL_cut), B_IS_OFFHAND);
							addPossibleRegularManueverChoice(B_MANUEVER_CHOICE_COUNT);
							B_MANUEVER_CHOICE_PROBABILITIES[B_MANUEVER_CHOICE_COUNT] = B_VIABLE_PROBABILITY;
							B_MANUEVER_CHOICE_COUNT++;
							curAggr = aggr;
						}
					}
				}
			}
		}
		if (AVAIL_thrust > 0) {
			B_BS_REQUIRED = B_BS_REQUIRED_DMG_DEFAULT;
			cp  = availableCP - getCostOfAvail(AVAIL_thrust);
			if ( cp > 0 ) {
				tn = getATNOfManuever("thrust");
				for (i in CURRENT_OPPONENT.body.thrustStartIndex...CURRENT_OPPONENT.body.zones.length) {
					B_BS_REQUIRED += getTargetZoneAverageAVOffset(i, B_EQUIP);
					cpToUse  = checkCostFunc(cp, tn, threshold, againstRoll, againstTN, (flags & FLAG_USE_ALL_CP) != 0 );
					if (cpToUse > 0) {
						aggr = useCheapestMult*cpToUse +  (1 - B_VIABLE_PROBABILITY);
						if (aggr <= curAggr) {
							if (aggr != curAggr) B_MANUEVER_CHOICE_COUNT = 0;
							MANUEVER_CHOICE.setAttack("thrust", cpToUse, tn, i, getCostOfAVAIL(AVAIL_thrust), B_IS_OFFHAND);
							addPossibleRegularManueverChoice(B_MANUEVER_CHOICE_COUNT);
							B_MANUEVER_CHOICE_PROBABILITIES[B_MANUEVER_CHOICE_COUNT] = B_VIABLE_PROBABILITY;
							B_MANUEVER_CHOICE_COUNT++;
							curAggr = aggr;
						}
					}
				}
			}
		}
		
		if (B_MANUEVER_CHOICE_COUNT > 0) {
			var randIndex:Int = Std.int(Math.random() * B_MANUEVER_CHOICE_COUNT);
			B_MANUEVER_CHOICES[randIndex].copyTo(MANUEVER_CHOICE);
			B_VIABLE_PROBABILITY_GET = B_MANUEVER_CHOICE_PROBABILITIES[randIndex];
			return true;
		}
		
		return false;
	
	}
	
	private static function getFBDefense(favorable:Bool, availableCP:Int,  againstRoll:Int = 0,  againstTN:Int = 1, heuristic:Bool = true, flags:Int = 0, customThreshold:Float=0):Bool {
		var threshold:Float = customThreshold != 0 ? customThreshold : favorable ? P_THRESHOLD_FAVORABLE : P_THRESHOLD_BORDERLINE;
		var safetyCost:Int;
			B_VIABLE_HEURISTIC = false;
		var result:Bool = heuristic ? getASuitableDefense(threshold, availableCP,  againstRoll, againstTN, false, favorable,  (flags & FLAG_USE_ALL_CP) != 0) : false;
		
		if ( result && (flags & FLAG_BORDERLINE_DEF_SAFETY) != 0) {
			safetyCost = checkCostAntiFavorability(availableCP, MANUEVER_CHOICE.manueverTN, P_RECKLESS, againstRoll, againstTN, false, 0, B_BS_REQUIRED_DMG_DEFAULT );
			if (safetyCost > 0) {
				if (MANUEVER_CHOICE.manueverCP < safetyCost ) {
					MANUEVER_CHOICE.manueverCP = safetyCost;
				}
			}
			else {
				result = false;
			}
		}
		
		if (result) {
			B_VIABLE_PROBABILITY_GET = B_VIABLE_PROBABILITY;
			B_VIABLE_HEURISTIC = true;
			
			
			return true;		
		}
		
		// consider all possible combinations as last resort (exaustive search to get best probabilty ..with/without cheapest cost )
		var cp:Int  = availableCP;
		var cpToUse:Int;
		var useCheapestMult:Int = (flags & FLAG_GET_CHEAPEST) != 0 ? 1 : 0;
		var aggr:Float;	
		B_MANUEVER_CHOICE_COUNT = 0;
		
		var curAggr:Float = 9999999999999;
		var tn:Int;
		var checkCostFunc:Int->Int->Float->Int->Int->Bool->Int = favorable ? checkCostViability : checkCostViabilityBorderline;
		
		if (AVAIL_block > 0) {
			B_BS_REQUIRED = B_BS_REQUIRED_DEFAULT;
			cp  = availableCP - getCostOfAvail(AVAIL_block);
			if ( cp > 0 ) {
				tn = getDTNOfManuever("block");
				cpToUse  = checkCostFunc(cp, tn, threshold, againstRoll, againstTN, (flags & FLAG_USE_ALL_CP) != 0 );
				if ((cpToUse > 0) && (flags & FLAG_BORDERLINE_DEF_SAFETY) != 0) {
					safetyCost = checkCostAntiFavorability(cp, tn, P_RECKLESS, againstRoll, againstTN, false, 0, B_BS_REQUIRED_DMG_DEFAULT );  
					if (safetyCost > 0) {
						if (cpToUse < safetyCost ) {
							cpToUse = safetyCost;
						}
					}
					else {
						cpToUse = 0;
					}
				}
				
				if (cpToUse > 0) {
					aggr = useCheapestMult*cpToUse +  (1 - B_VIABLE_PROBABILITY);
					if (aggr <= curAggr) {
						if (aggr != curAggr) B_MANUEVER_CHOICE_COUNT = 0;
						MANUEVER_CHOICE.setDefend("block", cpToUse, tn, getCostOfAVAIL(AVAIL_block), true);
						addPossibleRegularManueverChoice(B_MANUEVER_CHOICE_COUNT);
						B_MANUEVER_CHOICE_PROBABILITIES[B_MANUEVER_CHOICE_COUNT] = B_VIABLE_PROBABILITY;
						B_MANUEVER_CHOICE_COUNT++;
					}
				}
			}
		}
		if (AVAIL_parry > 0) {
			B_BS_REQUIRED = B_BS_REQUIRED_DEFAULT;
			cp  = availableCP - getCostOfAvail(AVAIL_parry);
			if ( cp > 0 ) {
				tn = getDTNOfManuever("parry");
				cpToUse  = checkCostFunc(cp, tn, threshold, againstRoll, againstTN, (flags & FLAG_USE_ALL_CP) != 0 );
				if ((cpToUse > 0) && (flags & FLAG_BORDERLINE_DEF_SAFETY) != 0) {
					safetyCost = checkCostAntiFavorability(cp, tn, P_RECKLESS, againstRoll, againstTN, false, 0, B_BS_REQUIRED_DMG_DEFAULT );  
					if (safetyCost > 0) {
						if (cpToUse < safetyCost ) {
							cpToUse = safetyCost;
						}
					}
					else {
						cpToUse = 0;
					}
				}
				
				if (cpToUse > 0) {
					aggr = useCheapestMult*cpToUse +  (1 - B_VIABLE_PROBABILITY);
					if (aggr <= curAggr) {
						if (aggr != curAggr) B_MANUEVER_CHOICE_COUNT = 0;
						MANUEVER_CHOICE.setDefend("parry", cpToUse, tn, getCostOfAVAIL(AVAIL_parry), B_IS_OFFHAND);
						addPossibleRegularManueverChoice(B_MANUEVER_CHOICE_COUNT);
						B_MANUEVER_CHOICE_PROBABILITIES[B_MANUEVER_CHOICE_COUNT] = B_VIABLE_PROBABILITY;
						B_MANUEVER_CHOICE_COUNT++;
					}
				}
			}
		}
		if (AVAIL_partialevasion > 0) {
			B_BS_REQUIRED = B_BS_REQUIRED_DEFAULT;  // if don't wish to sezie intitiative, B_BS_REQUIRED can be set to zero
			cp  = availableCP - getCostOfAvail(AVAIL_partialevasion) - 2;  // -2 enforce prefer option to be able to seize initiative?
			if ( cp > 0 ) {
				tn = getDTNOfManuever("partialevasion");
				cpToUse  = checkCostFunc(cp, tn, threshold, againstRoll, againstTN, (flags & FLAG_USE_ALL_CP) != 0 );
				if ((cpToUse > 0) && (flags & FLAG_BORDERLINE_DEF_SAFETY) != 0) {
					safetyCost = checkCostAntiFavorability(cp, tn, P_RECKLESS, againstRoll, againstTN, false, 0, B_BS_REQUIRED_DMG_DEFAULT );  
					if (safetyCost > 0) {
						if (cpToUse < safetyCost ) {
							cpToUse = safetyCost;
						}
					}
					else {
						cpToUse = 0;
					}
				}
				
				if (cpToUse > 0) {
					aggr = useCheapestMult*cpToUse +  (1 - B_VIABLE_PROBABILITY);
					if (aggr < curAggr) {
						if (aggr != curAggr) B_MANUEVER_CHOICE_COUNT = 0;
						MANUEVER_CHOICE.setDefend("partialevasion", cpToUse, tn, getCostOfAVAIL(AVAIL_partialevasion), false);
						addPossibleRegularManueverChoice(B_MANUEVER_CHOICE_COUNT);
						B_MANUEVER_CHOICE_PROBABILITIES[B_MANUEVER_CHOICE_COUNT] = B_VIABLE_PROBABILITY;
						B_MANUEVER_CHOICE_COUNT++;
					}
				}
			}
		}
		
		if (B_MANUEVER_CHOICE_COUNT > 0) {
			var randIndex:Int = Std.int(Math.random() * B_MANUEVER_CHOICE_COUNT);
			B_MANUEVER_CHOICES[randIndex].copyTo(MANUEVER_CHOICE);
			B_VIABLE_PROBABILITY_GET = B_MANUEVER_CHOICE_PROBABILITIES[randIndex];
			return true;
		}
		
		return false;
	}
	
	@return("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE", "B_VIABLE_HEURISTIC")
	public static inline function getFavorableDefense(availableCP:Int,  againstRoll:Int = 0,  againstTN:Int = 1, heuristic:Bool=true, flags:Int=0):Bool {
		return getFBDefense(true, availableCP, againstRoll, againstTN, heuristic, flags);
	}
	
	@return("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE", "B_VIABLE_HEURISTIC")
	@inspect([ { inspect:{min:0} }, { inspect:{min:0} }, { inspect:{min:1} }, { inspect:null  }, { inspect:null, bitmask:"FLAG" },  { inspect:{min:0, display:"range", step:0.01, max:1}} ]) 
	public static inline function getBorderlineDefense(availableCP:Int, againstRoll:Int = 0,  againstTN:Int = 1, heuristic:Bool=true, flags:Int=0, customThreshold:Float=0):Bool {
		return getFBDefense(false, availableCP, againstRoll, againstTN, heuristic, flags, customThreshold);
	}
		
	//@inspect
	private static function getFleeOrDefend(favorable:Bool, availableCP:Int,  againstRoll:Int = 0,  againstTN:Int = 1, heuristic:Bool = true, flags:Int = 0, customThreshold:Float = 0, secondExchange:Bool=false):Bool {
		var resultFirst:Bool = getFlee(favorable, availableCP,  againstRoll,  againstTN, heuristic, flags, customThreshold, secondExchange) ;
		if (resultFirst && (flags & FLAG_GET_CHEAPEST)!=0) {    // warning: assumes flee uses cheapest possible outlay due to lowest TN  and cost is zero!
			return resultFirst;
		}
		
		var fleeLikelihood:Float = TROSAI.getChanceToSucceedContest(MANUEVER_CHOICE.manueverCP, MANUEVER_CHOICE.manueverTN, againstRoll, againstTN, 1, true);
		var resultSecond:Bool = getFBDefense(favorable, availableCP, againstRoll, againstTN, heuristic, flags, customThreshold);
		return resultSecond ?  ( !resultFirst ||  TROSAI.getChanceToSucceedContest(MANUEVER_CHOICE.manueverCP, MANUEVER_CHOICE.manueverTN, againstRoll, againstTN, 1, true)  >= fleeLikelihood   ?   resultSecond : getDesperateFlee(availableCP, secondExchange) ) : (resultFirst &&  getDesperateFlee(availableCP, secondExchange) );
	}
	
	
	public static function minimalDefenseFirst(availableCP:Int,  againstRoll:Int = 0,  againstTN:Int = 1, enemyCPInReserve:Int = 0):Bool {
		var cp:Int;
		if (   getFlee(false, availableCP, enemyCPInReserve, getPredictedOpponentATN(), false, FLAG_GET_CHEAPEST, 0, true) ) {  // simulate 2nd exchange fleeing minimal
					cp = availableCP - MANUEVER_CHOICE.manueverCP;
					if ( getBorderlineDefense(cp, againstRoll, againstTN, true, (FLAG_USE_ALL_CP | FLAG_BORDERLINE_DEF_SAFETY), 0.0001) ) {
						// usually, this will only work if you've got a lot of heavy armor to protect yourself
						return true;
					}
				}
		return false;
	}
	
	private static inline function minimalDefenseOnly(availableCP:Int,  againstRoll:Int = 0,  againstTN:Int = 1, flags:Int=0):Bool {
	
			return getBorderlineDefense(availableCP, againstRoll, againstTN, true, flags | FLAG_BORDERLINE_DEF_SAFETY, 0.0001);
	}
	
//	/*
		private static function lastDitchFleeOrDefend(availableCP:Int, threatManuever:AIManueverChoice, secondExchange:Bool = false, enemyCPInReserve:Int = 0):Bool {
			var cpToUse:Int;
			var cpLeft:Int;
			var cpRight:Int;
			var isDamaging:Bool = ManueverSheet.isDamagingManuever(threatManuever.manuever);
			if (!secondExchange) {  // first exchange
				var opponentATN:Int = getPredictedOpponentATN();
				var minCPRequired:Int = checkCostViabilityWithBs(availableCP, FLEE_TN, P_THRESHOLD_BORDERLINE, enemyCPInReserve, opponentATN, false, 0);
				if (minCPRequired > 0) {
					cpLeft = availableCP - minCPRequired;
					if (isDamaging ?  minimalDefenseOnly(cpLeft, threatManuever.manueverCP, threatManuever.manueverTN, FLAG_USE_ALL_CP) :  getFBDefense(false, cpLeft, threatManuever.manueverCP, threatManuever.manueverTN, true, FLAG_USE_ALL_CP, 0) ) {
						cpToUse = MANUEVER_CHOICE.manueverCP;
						cpRight = checkCostViabilityWithBs(availableCP, FLEE_TN, P_THRESHOLD_FAVORABLE, enemyCPInReserve, opponentATN, false, 1);
						if (cpRight == 0) {
							cpRight = checkCostViabilityWithBs(availableCP, FLEE_TN, P_THRESHOLD_BORDERLINE, enemyCPInReserve, opponentATN, false, 1);
						}
						
						if (cpRight > 0) {
							cpRight = availableCP - cpRight - 1;
							if (cpToUse < cpRight) {
								cpToUse = cpRight;
								MANUEVER_CHOICE.manueverCP = cpToUse;
							}
						}
						
						return true;
					}
					else {
						
						// Compare cpToUse vs Flee probability
					//	trace("What to use?:"+cpLeft);
						return getFleeOrDefend(false, cpLeft, threatManuever.manueverCP, threatManuever.manueverTN, true, FLAG_USE_ALL_CP, 0.00000001, secondExchange);
						
						
					}
				}
		
					return getDesperateFlee(availableCP, secondExchange) || getFleeOrDefend(false, availableCP, threatManuever.manueverCP, threatManuever.manueverTN, true, FLAG_USE_ALL_CP, 0.00000001, secondExchange);
				
			}
			
			
			return getFleeOrDefend(false, availableCP, threatManuever.manueverCP, threatManuever.manueverTN, true, FLAG_USE_ALL_CP, 0.00000001, secondExchange);
			
			//return false;
		}
	//*/
	
	
	/*
	private static function lastDitchFleeOrDefend(availableCP:Int, threatManuever:AIManueverChoice, secondExchange:Bool = false, enemyCPInReserve:Int = 0):Bool {
		var cp:Int;
		//isDamagingThreat:Bool, availableCP:Int,  againstRoll:Int = 0,  againstTN:Int = 1
		var againstRoll:Int = threatManuever.manueverCP;
		var againstTN:Int = threatManuever.manueverTN;
		var isDamagingThreat:Bool = ManueverSheet.isDamagingManuever(threatManuever.manuever);
		
		if (enemyCPInReserve < 0) enemyCPInReserve = 0;
		
		
		if (!secondExchange) {		// first exchange
			if (isDamagingThreat && AVAIL_fullevasion > 0) {   
					// no considerations here atm
					//minimalDefenseOnly(availableCP, againstRoll, againstTN, 0) ||
					if ( getBorderlineDefense(availableCP, againstRoll, againstTN, true,  secondExchange ? FLAG_USE_ALL_CP : 0 , 0)  ||   getDesperateFleeOrDefend(availableCP, againstRoll, againstTN, true, secondExchange ? FLAG_USE_ALL_CP : 0, 0, secondExchange,0, 0,isDamagingThreat )) {
					
		
					if ( !isFleeingManuever(MANUEVER_CHOICE.manuever)  ) {  // defending with psosibly almost everything
						// detect if too little CP left
						cp = availableCP  - MANUEVER_CHOICE.getManueverCPSpent();
						//&& checkCostViabilityWithBs(enemyCPInReserve, getPredictedOpponentATN(), 1-P_RECKLESS, cp, MANUEVER_CHOICE.manueverTN, true, B_BS_REQUIRED_DEFAULT)
						var cpToUseForMinimalFlee:Int;
						if (enemyCPInReserve >= B_BS_REQUIRED_DMG_DEFAULT  && (cpToUseForMinimalFlee=checkCostViabilityWithBs(cp, FLEE_TN, P_THRESHOLD_BORDERLINE, enemyCPInReserve, getPredictedOpponentATN(), false, 1))==0 ) {  // todo: determine if got available minimum cp required left releative to enemy's
							if (  minimalDefenseOnly(availableCP, againstRoll, againstTN, 0))  {
								// usually, this will only work if you've got a lot of heavy armor to protect yourself
								// maximise chance to flee later
								if (  (cpToUseForMinimalFlee = checkCostViabilityWithBs( availableCP - MANUEVER_CHOICE.getManueverCPSpent() , FLEE_TN, P_THRESHOLD_BORDERLINE, enemyCPInReserve, getPredictedOpponentATN(), false, B_BS_REQUIRED_DMG_DEFAULT)) > 0  ) {
									//(cpToUseForMinimalFlee = checkCostViabilityWithBs( availableCP - MANUEVER_CHOICE.getManueverCPSpent() , FLEE_TN, P_THRESHOLD_FAVORABLE, enemyCPInReserve, getPredictedOpponentATN(), false, 1));
									//if ( cpToUseForMinimalFlee> 0 && availableCP - MANUEVER_CHOICE.getManueverCPSpent() > cpToUseForMinimalFlee) MANUEVER_CHOICE.manueverCP = availableCP - cpToUseForMinimalFlee - MANUEVER_CHOICE.cost;
									trace("minimal defense first with flee successful");
									return true;
								}
							}
						}
						else {
							trace("defending with armor ok");
							return true;  // should be deemed ok with remaining cp left against enemy's
						}
					}
					else {
						trace("fleeing should be ok..but forced to..");
						return true;  // fleeing ok...
					}
				}
				else return false;
				
			}
			else {  // Got no full evasion yet on first exchange, consider defend minimally to hopefully be able to full evade successfuly next exchange for refreshing next round
				if ( isDamagingThreat &&  minimalDefenseFirst(availableCP, againstRoll, againstTN, enemyCPInReserve))  {
						// usually, this will only work if you've got a lot of heavy armor to protect yourself
						return true;
				}
			}
		}
		else {	 // second exchange
			// no considerations here atm
		}
		
		trace("bopian flee or defend");
		return getDesperateFleeOrDefend(availableCP, againstRoll, againstTN, true, secondExchange ? FLAG_USE_ALL_CP : 0, 0, secondExchange, enemyCPInReserve, 0, isDamagingThreat );
	}
	
	

	private static function getDesperateFleeOrDefend( availableCP:Int,  againstRoll:Int = 0,  againstTN:Int = 1, heuristic:Bool = true, flags:Int = 0, customThreshold:Float = 0, secondExchange:Bool=false, enemyCPInReserve:Int=0, fleeVsDefendMarginMax:Float=0, useArmor:Bool=true):Bool {
		
		var resultFirst:Bool =getDesperateFlee(availableCP, secondExchange);
		if (resultFirst && (flags & FLAG_GET_CHEAPEST)!=0) {     // warning: assumes flee uses cheapest possible outlay due to lowest TN and cost is zero!
			return true;
		}
	
		
		var fleeLikelihood:Float = TROSAI.getChanceToSucceedContest(MANUEVER_CHOICE.manueverCP, MANUEVER_CHOICE.manueverTN, againstRoll, againstTN, 1, true);
		
		//flags |= FLAG_BORDERLINE_DEF_SAFETY;
		
		var availableCPForRegularDef:Int = availableCP;
		if (enemyCPInReserve > 0 ) {
			// spam all for defense or can reserve some	
			var reduc:Int;
			if ( (reduc=checkCostViabilityWithBs(availableCP, FLEE_TN, P_THRESHOLD_BORDERLINE, enemyCPInReserve, getPredictedOpponentATN(), false, B_BS_REQUIRED_DMG_DEFAULT)) > 0 ) {
				availableCPForRegularDef -= reduc;
			}
			else if (resultFirst) {
				return true;
			}
		}
		var dmgBarrier:Int = useArmor ? B_BS_REQUIRED_DMG_DEFAULT : 1;
		var singleExchangeOverwrite:Bool =  false;// enemyCPInReserve < dmgBarrier  || secondExchange;
		if (singleExchangeOverwrite) fleeVsDefendMarginMax = 0.1;
		
		
		var resultSecond:Bool = !useArmor ?  getFBDefense(false, availableCPForRegularDef, againstRoll, againstTN, heuristic, flags, customThreshold ) : singleExchangeOverwrite ? getBorderlineDefense(availableCPForRegularDef, againstRoll, againstTN, true, (FLAG_USE_ALL_CP), 0.0001) :   minimalDefenseOnly(availableCPForRegularDef, againstRoll, againstTN, flags);
		

		if (!resultSecond && !resultFirst) {  // no fleeing or favorable/borderline defense option available...forced to desperately defend with whatever that is remaining
			if ( minimalDefenseOnly(availableCP, againstRoll, againstTN, flags) ) {
				return true;
			}
			var def:String = getRegularDefense(availableCP, 0, false);   // force a certain defense	
			if (def != null) {
				availableCP -= getCostOfManuever(def);
				if (availableCP > 0) {
					MANUEVER_CHOICE.setDefend(def, (flags & FLAG_USE_ALL_CP) != 0 ? availableCP : Std.int(Math.ceil(availableCP * .5)), getDTNOfManuever(def), getCostOfManuever(def), B_IS_OFFHAND );
					return true;
				}
			}
			else return false;		
		}
		
		
		var defLikelihood:Float = TROSAI.getChanceToSucceedContest(MANUEVER_CHOICE.manueverCP, MANUEVER_CHOICE.manueverTN, againstRoll, againstTN, 1, true);
	
		if (WISH_TO_REGAIN_STANCE && resultFirst && fleeLikelihood > defLikelihood) {  // 3rd condition not required?
			return getDesperateFlee(availableCP, secondExchange);
		}
		
		
		
		return resultSecond ?   !resultFirst || !weightedChoiceBetween2(fleeLikelihood, defLikelihood, fleeVsDefendMarginMax )   ?   resultSecond : getDesperateFlee(availableCP, secondExchange) :
			(resultFirst && getDesperateFlee(availableCP, secondExchange));
	}
*/
	
	//@inspect([	{ inspect:{min:0, display:"range", step:0.01, max:1} },	{ inspect:{min:0, display:"range", step:0.01, max:1} }  ])
	private static function weightedChoiceBetween(trueConditionProbability:Float, falseConditionProbability:Float):Bool {
		return Math.random()*(trueConditionProbability + falseConditionProbability)  <= trueConditionProbability;
	}
	
	//@inspect([	{ inspect:{min:0, display:"range", step:0.01, max:1} },	{ inspect:{min:0, display:"range", step:0.01, max:1} }, { inspect:{min:0, display:"range", step:0.01, max:1} }   ])
	private static function weightedChoiceBetween2(trueConditionProbability:Float, falseConditionProbability:Float, maxMarginOfDifference:Float):Bool {
		return maxMarginOfDifference != 0 && absDiffF(trueConditionProbability, falseConditionProbability) > maxMarginOfDifference ?   trueConditionProbability >= falseConditionProbability :  Math.random()*(trueConditionProbability + falseConditionProbability)  <= trueConditionProbability;
	}
	
	private static inline function absDiffF(val:Float, val2:Float):Float {
		return val > val2 ?  val - val2 : val2 - val;
	}
	
	private static function getDesperateFlee(availableCP:Int, secondExchange:Bool):Bool {
		if (AVAIL_fullevasion > 0) {
			var cpToUseForFleeing:Int = getCPMaxForFleeing(availableCP, secondExchange);
			MANUEVER_CHOICE.setDefend("fullevasion", cpToUseForFleeing, getDTNOfManuever("fullevasion"), getCostOfAVAIL(AVAIL_fullevasion), false);

			return true;
		}
		return false;
	}
	
	private static function getFlee(favorable:Bool,  availableCP:Int,  againstRoll:Int = 0,  againstTN:Int = 1, heuristic:Bool = true, flags:Int = 0, customThreshold:Float=0, secondExchange:Bool = false):Bool {
		var threshold:Float = customThreshold != 0 ? customThreshold : favorable ? P_THRESHOLD_FAVORABLE : P_THRESHOLD_BORDERLINE;
		var cpToSpend:Int;
		if (AVAIL_fullevasion > 0) {
			var cpToUseForFleeing:Int = getCPMaxForFleeing(availableCP, secondExchange);
			if (favorable) {
				cpToSpend = checkCostViability( cpToUseForFleeing, FLEE_TN, threshold, againstRoll, againstTN, (flags & FLAG_USE_ALL_CP) !=0);
				if ( cpToSpend > 0 ) {
					MANUEVER_CHOICE.setDefend("fullevasion", cpToSpend, FLEE_TN, getCostOfAVAIL(AVAIL_fullevasion), false);
					return true;
				}
			}
			else {
				cpToSpend = checkCostViabilityBorderline( cpToUseForFleeing, FLEE_TN, threshold, againstRoll, againstTN, (flags & FLAG_USE_ALL_CP) !=0);
				if ( cpToSpend > 0 ) {
					MANUEVER_CHOICE.setDefend("fullevasion", cpToSpend, FLEE_TN, getCostOfAVAIL(AVAIL_fullevasion), false);
					return true;
				}
			}
			
		}
		return false;
	}
	
	static private inline function getCPMaxForFleeing(availableCP:Int, secondExchange:Bool):Int
	{
		return GameRules.FLEE_CAP == GameRules.FLEE_CAP_NONE || (GameRules.FLEE_CAP == GameRules.FLEE_CAP_BY_MOBILITY_EXCHANGE1 && secondExchange) ? availableCP : (availableCP > 6  ? 6 : availableCP);
	}
	

	private static  function tryBestPossibleDefenseBoliao(cp:Int, cp2:Int, threatManuever:AIManueverChoice, secondExchange:Bool):Bool {
			MANUEVER_COMBO_SET = 0;
			
			return getSpecialDefWithReturnAttack(cp, cp2, threatManuever.manueverCP, threatManuever.manueverTN, 0, secondExchange) ||   lastDitchFleeOrDefend(  cp, threatManuever, secondExchange, cp2- threatManuever.manueverCP);
	}
	
	
	private static function tryBestPossibleAttackBoliao(cp:Int, cp2:Int, threatManuever:AIManueverChoice, secondExchange:Bool):Bool {
		MANUEVER_COMBO_SET = 0;
		var atk:String = getRegularAttackOrAdvantageMove(cp, 0, (threatManuever != null ? threatManuever.manueverCP : -1), (threatManuever!=null ?  threatManuever.manueverTN : 1 ));   // force a certain defense
		if (atk != null) {
			var cost:Int;
			cp -= cost = getCostOfManuever(atk);
			if (cp > 0) {
				var atn:Int = getATNOfManuever(atk);
				var cpToUse:Int = checkCostViabilityBorderline(cp, cp2, P_THRESHOLD_BORDERLINE, (secondExchange ? cp2 : Std.int(Math.ceil(cp2 * .5))), getPredictedOpponentDTN(), secondExchange);
				MANUEVER_CHOICE.setAttack(atk, secondExchange ? cp : (cpToUse > 0 ? cpToUse : ( CAN_DESPERATE_ALPHASTRIKE && Math.random() < DESPERATE_ALPHASTRIKE_CHANCE ?  cp : Std.int(Math.ceil(cp * .5))  )  ), atn, getRegularTargetZone(atk, atn, cp),  cost, B_IS_OFFHAND );
				return true;
			}
		}
		return false;		
	}
	

	
	private static var MOCK_RETURN_ATTACK:AIManueverChoice = new AIManueverChoice();
	private static function tryBestPossibleAttackOrDefBoliao(cp:Int, cp2:Int, threatManuever:AIManueverChoice, secondExchange:Bool):Bool {
		MOCK_RETURN_ATTACK.manueverCP = cp2;
		MOCK_RETURN_ATTACK.manueverTN = getPredictedOpponentATN();	
		MANUEVER_COMBO_SET = 0;
		
		if (secondExchange) { 
			if (WISH_TO_REGAIN_STANCE) {
				if ( tryBestPossibleDefWithInitiativeBoliao(cp, cp2, threatManuever, secondExchange)) {
					return true;
				}
			}
		}
		else {
			if (!CURRENTLY_AGGROED && WISH_TO_REGAIN_STANCE) {  // if not forced to attack and wish to regain stance
				if ( tryBestPossibleDefWithInitiativeBoliao(cp, cp2, threatManuever, secondExchange)) {
					return true;
				}
				
			}
		}
		return tryBestPossibleAttackBoliao(cp, cp2, null, secondExchange);
	}
	private static inline function tryBestPossibleDefWithInitiativeBoliao(cp:Int, cp2:Int, threatManuever:AIManueverChoice, secondExchange:Bool):Bool {
		var result:Bool = false;
		if ( getFleeOrDefend(false, cp, MOCK_RETURN_ATTACK.manueverCP, MOCK_RETURN_ATTACK.manueverTN, true, 0, 0, secondExchange) ) {
			if ( isFleeingManuever(MANUEVER_CHOICE.manuever) ) {
				result = true;
			}
			else if ( cp > 2 && getBorderlineDefense(cp - 2, MOCK_RETURN_ATTACK.manueverCP, MOCK_RETURN_ATTACK.manueverTN, true, (secondExchange ? FLAG_USE_ALL_CP : 0), 0 ) )  {
				MANUEVER_CHOICE.waitForQuickDefense();
				result = true;
				
			}
		}
		return result;
	}
	
	
	private static inline function addPossibleRegularManueverChoice(index:Int):Void {
		MANUEVER_CHOICE.copyTo( index >= B_MANUEVER_CHOICES.length ? (B_MANUEVER_CHOICES[index] = new AIManueverChoice()) : B_MANUEVER_CHOICES[index] );
	}

	
	private static function getAdvantageManuever(manueverName:String, favorable:Bool, availableCP:Int,  againstRoll:Int = 0,  againstTN:Int = 1, flags:Int = 0, customThreshold:Float = 0, preferedRS:Int = 1, defensive:Bool = false, alwaysUseOffhand:Bool=false):Bool {
		var threshold:Float = customThreshold!= 0 ? customThreshold : favorable ? P_THRESHOLD_FAVORABLE : P_THRESHOLD_BORDERLINE;
		//if (AVAIL_disarm > 0) {
			availableCP -= getCostOfManuever(manueverName);
			if (availableCP > 0) {
				B_BS_REQUIRED = preferedRS;
				var tn:Int = defensive ? getDTNOfManuever(manueverName) : getATNOfManuever(manueverName);
				if (tn == 0 || tn == IMPOSSIBLE_TN) return false;
				var costing:Int = favorable ? checkCostViability(availableCP, tn, threshold, againstRoll, againstTN, (flags & FLAG_USE_ALL_CP) != 0) : checkCostViabilityBorderline(availableCP, tn, threshold, againstRoll, againstTN, (flags & FLAG_USE_ALL_CP) != 0) ;
				B_BS_REQUIRED = B_BS_REQUIRED_DEFAULT;
			
				
				if (costing > 0) {
					if (defensive) {
						B_VIABLE_PROBABILITY_GET = B_VIABLE_PROBABILITY;
						MANUEVER_CHOICE.setDefend(manueverName, costing, tn, getCostOfManuever(manueverName), alwaysUseOffhand || B_IS_OFFHAND);
					}
					else {
						B_VIABLE_PROBABILITY_GET = B_VIABLE_PROBABILITY;
						MANUEVER_CHOICE.setAttack(manueverName, costing, tn, 0, getCostOfManuever(manueverName), alwaysUseOffhand || B_IS_OFFHAND);
					}
					return true;
				}
			}
		//}
		return false;
	}
	
	@return("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static function getBlockOpenAndStrike(favorable:Bool, availableCP:Int,  againstRoll:Int = 0,  againstTN:Int = 1, flags:Int = 0, customThreshold:Float = 0, preferedRS:Int=1):Bool {
		return AVAIL_blockopenstrike > 0 ? getAdvantageManuever("blockopenstrike", favorable, availableCP, againstRoll, againstTN, flags, customThreshold, preferedRS, true) : false;
	}
	
	@return("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static inline function getRota(favorable:Bool, availableCP:Int,  againstRoll:Int ,  againstTN:Int , flags:Int = 0, customThreshold:Float = 0, preferedRS:Int=1):Bool {
		return AVAIL_rota > 0 ? getAdvantageManuever("rota", favorable, availableCP, againstRoll, againstTN, flags, customThreshold, preferedRS, true) : false;
	}
	
	@return("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static inline function getCounter(favorable:Bool, availableCP:Int,  againstRoll:Int,  againstTN:Int, flags:Int = 0, customThreshold:Float = 0, preferedRS:Int=1):Bool {
		return AVAIL_counter > 0 ?  getAdvantageManuever("counter", favorable, availableCP, againstRoll, againstTN, flags, customThreshold, preferedRS, true) : false;
	}
	
	@return("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static inline function getExpulsion(favorable:Bool, availableCP:Int,  againstRoll:Int,  againstTN:Int, flags:Int = 0, customThreshold:Float = 0, preferedRS:Int=1):Bool {
		return AVAIL_expulsion > 0 ? getAdvantageManuever("expulsion", favorable, availableCP, againstRoll, againstTN, flags, customThreshold, preferedRS, true) : false;
	}
	
	
	private static inline var MAX_COUNTERING_AV:Int = 8;
	
	
	private static var DEF_AGGR:Float = 0;
	
	@return("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE", "DEF_AGGR", "B_MANUEVER_CHOICES", "B_MANUEVER_CHOICE_COUNT")
	@inspect([ {inspect:{min:0}},  {inspect:{min:0}}, {inspect:{min:0}}, {inspect:{min:1}}, { inspect:{min:0, display:"range", step:0.01, max:1} } ]) 
	public static function getSpecialDefWithReturnAttack( availableCP:Int, againstCP:Int, againstRoll:Int,  againstTN:Int, customThreshold:Float = 0, secondExchange:Bool = false ):Bool {
	
		var minCPRemainRequired:Int;
		var cost:Int;
		var cpToUse:Int;
		var weapon:Weapon = WeaponSheet.getWeaponByName(B_EQUIP);
		var offhandWeap:Weapon = WeaponSheet.getWeaponByName(D_EQUIP);
		var dtn:Int = weapon != null ? weapon.dtn : 0;
		var blockDTN:Int = offhandWeap != null ?  offhandWeap.dtn : 0;
		var atn:Int = weapon != null ?weapon.atn : 0;
		var atn2:Int  = weapon != null ? weapon.atn2 : 0;
		
		var pool:Int = availableCP;
		var enemyDTN:Int = getPredictedOpponentDTN();
		
		
	    var enemyCPLeft:Int = againstCP - againstRoll;
		var minCPLeftRequired:Int;
		var cpToSave:Int;
		var aggr:Float;
		var usingReturnStrikeTN:Int;
		var curAggr:Float = 99999999;
		
		if (dtn == 0) return false;
		
		B_MANUEVER_CHOICE_COUNT = 0;
		var initialCount:Int = 0;
		var threshold:Float = customThreshold != 0 ? customThreshold : P_THRESHOLD_FAVORABLE;
		
		if (AVAIL_counter > 0) {
			cost = getCostOfAVAIL(AVAIL_counter);
			B_BS_REQUIRED = cost+1;
			if ( checkCostViability(againstRoll, againstTN, P_THRESHOLD_ANTI_FAVORABLE,  0, 1, false) > 0) {
				B_BS_REQUIRED = 1;
				usingReturnStrikeTN = Std.int(Math.round((atn + atn2) / 2));
				cpToSave = secondExchange ? 0 :  checkCostViabilityBorderline(pool, usingReturnStrikeTN, P_THRESHOLD_BORDERLINE, enemyCPLeft, enemyDTN, false);
				aggr = dtn + usingReturnStrikeTN + (getAverageOpponentCounterAV()/MAX_COUNTERING_AV);
				aggr = cpToSave + cost + aggr / 20;
				availableCP = pool - cpToSave;
				B_BS_REQUIRED =1;
				cpToUse = availableCP > 0 ? checkCostViability(availableCP, dtn, threshold, againstRoll, againstTN, true) : 0;
				if (cpToUse > 0) {
					if (aggr <= curAggr) {
						if (aggr != curAggr) B_MANUEVER_CHOICE_COUNT = initialCount;
						MANUEVER_CHOICE.setDefend("counter", cpToUse, dtn, cost,  B_IS_OFFHAND);
						addPossibleRegularManueverChoice(B_MANUEVER_CHOICE_COUNT);
						B_MANUEVER_CHOICE_PROBABILITIES[B_MANUEVER_CHOICE_COUNT] = B_VIABLE_PROBABILITY;
						B_MANUEVER_CHOICE_COUNT++;
						curAggr = aggr;
					}
				}
			}
			B_BS_REQUIRED = B_BS_REQUIRED_DEFAULT;
		}
		if (AVAIL_rota > 0 ) {
			cost = getCostOfAVAIL(AVAIL_rota);
			B_BS_REQUIRED = cost+1;
			if ( checkCostViability(againstRoll, againstTN, P_THRESHOLD_ANTI_FAVORABLE, 0, 1, false) > 0) {
				B_BS_REQUIRED =1;
				usingReturnStrikeTN = atn;
				cpToSave =  secondExchange ? 0 : checkCostViabilityBorderline(pool, usingReturnStrikeTN, P_THRESHOLD_BORDERLINE, enemyCPLeft, enemyDTN, false);
				aggr =  dtn + usingReturnStrikeTN + (getAverageOpponentCounterAV()/MAX_COUNTERING_AV);
				aggr = cpToSave + cost + aggr / 20;
				availableCP = pool - cpToSave;
				B_BS_REQUIRED =1;
				cpToUse = availableCP > 0 ? checkCostViability(availableCP, dtn, threshold, againstRoll, againstTN, true) : 0;
				if (cpToUse > 0) {
					if (aggr <= curAggr) {
						if (aggr != curAggr) B_MANUEVER_CHOICE_COUNT = initialCount;
						MANUEVER_CHOICE.setDefend("rota", cpToUse, dtn, cost,  B_IS_OFFHAND);
						addPossibleRegularManueverChoice(B_MANUEVER_CHOICE_COUNT);
						B_MANUEVER_CHOICE_PROBABILITIES[B_MANUEVER_CHOICE_COUNT] = B_VIABLE_PROBABILITY;
						B_MANUEVER_CHOICE_COUNT++;
						curAggr = aggr;
					}
				}
			}
			B_BS_REQUIRED = B_BS_REQUIRED_DEFAULT;
		}
		
		
		// category 2 reset
		initialCount = B_MANUEVER_CHOICE_COUNT;
		curAggr = 99999999;
		
		if ( (AVAIL_blockopenstrike > 0 && blockDTN > 0)) {
			cost = getCostOfAVAIL(AVAIL_blockopenstrike);
			B_BS_REQUIRED = 1;
			usingReturnStrikeTN = atn2 < atn ? atn2 : atn;
			cpToSave =  secondExchange ? 0 : checkCostViabilityBorderline(pool, usingReturnStrikeTN, P_THRESHOLD_BORDERLINE, enemyCPLeft, enemyDTN, false);
			aggr = blockDTN + usingReturnStrikeTN + (getAverageOpponentCounterAV()/MAX_COUNTERING_AV);
			aggr =  cpToSave + cost + aggr / 20;
			availableCP = pool - cpToSave;
			B_BS_REQUIRED = cost;
			cpToUse = availableCP > 0 ? checkCostViability(availableCP, blockDTN, threshold, againstRoll, againstTN, true) : 0;
			if (cpToUse > 0) {
				if (aggr <= curAggr) {
					if (aggr != curAggr) B_MANUEVER_CHOICE_COUNT = initialCount;
					MANUEVER_CHOICE.setDefend("blockopenstrike", cpToUse, blockDTN, cost,  B_IS_OFFHAND);
					addPossibleRegularManueverChoice(B_MANUEVER_CHOICE_COUNT);
					B_MANUEVER_CHOICE_PROBABILITIES[B_MANUEVER_CHOICE_COUNT] = B_VIABLE_PROBABILITY;
					B_MANUEVER_CHOICE_COUNT++;
					curAggr = aggr;
				}
			}
			B_BS_REQUIRED = B_BS_REQUIRED_DEFAULT;
		}
		if (AVAIL_expulsion > 0 ) {
			cost = getCostOfAVAIL(AVAIL_expulsion);
			B_BS_REQUIRED = 1;
			usingReturnStrikeTN = atn2 ;
			availableCP = pool - cost;
			cpToSave =  secondExchange ? 0 : checkCostViabilityBorderline(availableCP, usingReturnStrikeTN, P_THRESHOLD_BORDERLINE, maxI(0, enemyCPLeft-B_BS_REQUIRED), enemyDTN, false);
			aggr = dtn + usingReturnStrikeTN + (getAverageOpponentCounterAV()/MAX_COUNTERING_AV);
			aggr = cpToSave + cost + aggr / 20;
			availableCP = pool - cpToSave - cost;
			B_BS_REQUIRED = 2;
			cpToUse = availableCP > 0 ? checkCostViability(availableCP, dtn, threshold, againstRoll, againstTN, true) : 0;
			if (cpToUse > 0) {
				if (aggr <= curAggr) {
					if (aggr != curAggr) B_MANUEVER_CHOICE_COUNT = initialCount;
					MANUEVER_CHOICE.setDefend("expulsion", cpToUse, dtn, cost,  B_IS_OFFHAND);
					addPossibleRegularManueverChoice(B_MANUEVER_CHOICE_COUNT);
					B_MANUEVER_CHOICE_PROBABILITIES[B_MANUEVER_CHOICE_COUNT] = B_VIABLE_PROBABILITY;
					B_MANUEVER_CHOICE_COUNT++;
					curAggr = aggr;
				}
			}
			B_BS_REQUIRED = B_BS_REQUIRED_DEFAULT;
		}
		
		DEF_AGGR = curAggr;
		if (B_MANUEVER_CHOICE_COUNT > 0) {
			var randIndex:Int = Std.int(Math.random() * B_MANUEVER_CHOICE_COUNT);
			B_MANUEVER_CHOICES[randIndex].copyTo(MANUEVER_CHOICE);
			B_VIABLE_PROBABILITY_GET = B_MANUEVER_CHOICE_PROBABILITIES[randIndex];
			return true;
		}
		
		return false;
	}
	
	///*  // likely to be yagni?
	  static private function getAverageOpponentCounterAV():Int 
	{
		
		return 0;
	}
	//*/
	
	private static inline function maxI(val:Int, val2:Int):Int {
		return val >= val2 ? val : val2;
	}
	

	
	//static
	@return("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static function getDisarm(favorable:Bool, availableCP:Int,  againstRoll:Int = 0,  againstTN:Int = 1, flags:Int = 0, customThreshold:Float = 0, preferedRS:Int=1, defensive:Bool=false, disarmOffhand:Bool=false):Bool {
		var result:Bool =  AVAIL_disarm > 0 ? getAdvantageManuever("disarm", favorable, availableCP, againstRoll, againstTN, flags, customThreshold, preferedRS, defensive) : false;
		MANUEVER_CHOICE.targetZone = disarmOffhand ? AIManueverChoice.TARGET_OFFHAND : AIManueverChoice.TARGET_WEAPON;
		return result;
	}
	@return("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static inline function getHook(favorable:Bool, availableCP:Int,  againstRoll:Int = 0,  againstTN:Int = 1, flags:Int = 0, customThreshold:Float = 0, preferedRS:Int=1):Bool {
		return AVAIL_hook > 0  ? getAdvantageManuever("hook", favorable, availableCP, againstRoll, againstTN, flags, customThreshold, preferedRS, false) : false;
	}
	
	@return("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static inline function getBindStrike(favorable:Bool, availableCP:Int, againstCP:Int,  againstRoll:Int=0,  againstTN:Int=1,flags:Int = 0, customThreshold:Float = 0, preferedRS:Int=1):Bool {
		return AVAIL_bindstrike > 0 ? getAdvantageManuever("bindstrike", favorable, availableCP, againstRoll, againstTN, flags, customThreshold, preferedRS, false, true) : false;
	}
	
	@return("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	public static function getBeat(favorable:Bool, availableCP:Int,  againstRoll:Int = 0,  againstTN:Int = 1, flags:Int = 0, customThreshold:Float = 0, preferedRS:Int=1, preferTargetMaster:Int=0):Bool {
		if ( AVAIL_beat > 0 ) {
			var result:Bool =  getAdvantageManuever("beat", favorable, availableCP, againstRoll, againstTN, flags, customThreshold, preferedRS, false);
			if (result) {
				var master:Int = CURRENT_OPPONENT.getMasterDTN();
				var shield:Int =  CURRENT_OPPONENT.getShieldDTN();
				MANUEVER_CHOICE.targetZone =  master == 0 || shield == 0 ? (shield == 0 ? AIManueverChoice.TARGET_WEAPON :  AIManueverChoice.TARGET_SHIELD)  :  (shield < master-preferTargetMaster ? AIManueverChoice.TARGET_SHIELD :  AIManueverChoice.TARGET_WEAPON);
			}
			return result;
		}
		return false;
	}
	
	
	
	@return("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	//@inspect
	public static function getAdvantageGainCPOffensiveMove(favorable:Bool, availableCP:Int,  againstRoll:Int = 0,  againstTN:Int = 1, flags:Int = 0, customThreshold:Float = 0, preferedRS:Int = 1, preferTargetMaster:Int = 0):Bool {
		B_BS_REQUIRED = B_BS_REQUIRED_DEFAULT;
		var threshold:Float = customThreshold != 0 ? customThreshold : favorable ? P_THRESHOLD_FAVORABLE : P_THRESHOLD_BORDERLINE;
		
		var manuever:String = getRegularAdvantageMove(availableCP, 0, againstRoll, againstTN);
		if (manuever != null) {
			var tn:Int = getATNOfManuever(manuever);
			var cost:Int = getCostOfManuever(manuever);
			availableCP -= cost;
			if (availableCP > 0) {
				
				var cpToUse:Int = favorable  ? checkCostViability(availableCP, tn, threshold, againstRoll, againstTN, (flags & FLAG_USE_ALL_CP) != 0) : checkCostViabilityBorderline(availableCP, tn, threshold, againstRoll, againstTN, (flags & FLAG_USE_ALL_CP) != 0);
			
				if (cpToUse > 0) {
					B_VIABLE_PROBABILITY_GET = B_VIABLE_PROBABILITY;
					MANUEVER_CHOICE.setAttack(manuever, cpToUse, tn, 0, cost, B_IS_OFFHAND);
					return true;
				}
			}
		}
		
		
		return false;
	}
	
	
		

	
	@inspect
	public static inline function getPredictedOpponentDTN():Int {
		return CURRENT_OPPONENT.getPredictedDTN();
	}
	
	@inspect
	public static inline function getPredictedOpponentATN():Int {
		return CURRENT_OPPONENT.getPredictedATN();
	}
	
	private function getPredictedDTN():Int {
		var weapon:Weapon;
		var dtn:Int = 7;
		
		weapon = (manueverUsingHands & Manuever.MANUEVER_HAND_MASTER) ==0 ? WeaponSheet.getWeaponByName(equipMasterhand) : null;
		if (weapon != null && weapon.dtn < dtn && weapon.dtn > 0) {
			dtn = weapon.dtn;
			
			
		}
		
		weapon = (manueverUsingHands & Manuever.MANUEVER_HAND_SECONDARY) == 0 ? WeaponSheet.getWeaponByName(equipOffhand) : null;
		if (weapon != null && weapon.dtn < dtn  && weapon.dtn > 0) {
			dtn = weapon.dtn;

		}
		
		return dtn;
	}
	
		private function getPredictedATN():Int {
		var weapon:Weapon;
		var atn:Int = 10;
		
		weapon = WeaponSheet.getWeaponByName(equipMasterhand);
		if (weapon != null ) {
			if (weapon.atn < atn && weapon.atn > 0) {
				atn = weapon.atn;
			}
			if (weapon.atn2 < atn && weapon.atn2> 0) {
				atn = weapon.atn2;
			}
		}
		
		weapon = WeaponSheet.getWeaponByName(equipOffhand);
		if (weapon != null) {
			if (weapon.atn < atn && weapon.atn > 0) {
				atn = weapon.atn;
			}
			if (weapon.atn2 < atn && weapon.atn2 > 0) {
				atn = weapon.atn2;
			}
		}
		return atn;
	}
	
	
	
	
	private inline function getOffhandDTN():Int {
		var weapon:Weapon = WeaponSheet.getWeaponByName(equipOffhand);
		return weapon != null ? weapon.dtn : 0;
	}
	
	private inline function getShieldDTN():Int {
		var weapon:Weapon = WeaponSheet.getWeaponByName(equipOffhand);
		return weapon != null && weapon.shield ? weapon.dtn : 0;
	}
	private inline  function getMasterDTN():Int {
		var weapon:Weapon = WeaponSheet.getWeaponByName(equipMasterhand);
		return weapon != null ? weapon.dtn : 0;
	}
	
	
	private function getHighestATNOrDTN():Int {
		var atn:Int = getPredictedATN();
		var dtn:Int = getPredictedDTN();
		return atn > dtn ? atn : dtn;
	}
	
	private inline function getDTNBetterMargin():Int {
		return  getPredictedATN() - getPredictedDTN();
	}
	
	private static inline function fluctuateLower(val:Float,lowerBy:Float):Float {
		lowerBy = lowerBy >= val ? val*.5 : lowerBy;
		val -= Math.random() * lowerBy;
		return val;
	}
	
	
	
	@inspect([ { inspect:{display:"selector"}, choices:"COMBO" }, { inspect:{min:0} }, { inspect:{min:0} } ]) 
	private static function getComboExchangeBudgetingWithInitiative(combo:Int, cp:Int, cp2:Int, threatManuever:AIManueverChoice=null):Vector<Int> {
		var lastDefault:Int;
		if (threatManuever!= null && threatManuever.manuever == "") threatManuever  = null;
		var dtn:Int = getPredictedOpponentDTN();
		var stipulateRemaining:Int;
	
		if (combo > 0) {	
			switch( combo) {
				// ai combos typically with initiative:
				case COMBO_PureMeanStrikes:	
					stipulateRemaining = Math.floor(cp2 * .5);
					if ( ( (getFavorableAttack(Math.floor(cp*.5), stipulateRemaining, dtn, false, FLAG_GET_CHEAPEST) || getAdvantageGainCPOffensiveMove(true, Math.floor(cp*.5), stipulateRemaining, dtn, FLAG_GET_CHEAPEST) ) && (cp-MANUEVER_CHOICE.getManueverCPSpent()) >=Math.ceil(cp*.5) )  || ( getBorderlineAttack(Math.floor(cp*.5), stipulateRemaining, dtn, false, FLAG_GET_CHEAPEST) || getAdvantageGainCPOffensiveMove(false, Math.floor(cp*.5), stipulateRemaining, dtn, FLAG_GET_CHEAPEST)) ) {
						cp -= MANUEVER_CHOICE.getManueverCPSpent();
						
						B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_1] = cp;  
						B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_1_ENEMY] =  Math.ceil(cp2*.5);
						B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_2] = MANUEVER_CHOICE.getManueverCPSpent();
						B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_2_ENEMY] = stipulateRemaining;  
						if ( getBorderlineAttack(cp, B_COMBO_EXCHANGE_BUDGET[1], dtn, false, FLAG_USE_ALL_CP) ||  getAdvantageGainCPOffensiveMove(false, cp, B_COMBO_EXCHANGE_BUDGET[1], dtn, FLAG_USE_ALL_CP) ) {
						
							return B_COMBO_EXCHANGE_BUDGET;
						}
					}
				case COMBO_HeavyFirstStrikes:	
					if (getAForcefulInitiativeAttack(P_THRESHOLD_FAVORABLE, cp, cp2, dtn, true, false, 0) ) {
					
						stipulateRemaining = 0;
						var consideredCP:Int = MANUEVER_CHOICE.getManueverCPSpent();
						
						lastDefault = B_BS_REQUIRED_DEFAULT;
						B_BS_REQUIRED_DEFAULT = 0;
						getFavorableAttack(cp,  Std.int(cp2 * .5), dtn, false, FLAG_GET_CHEAPEST);
						if (MANUEVER_CHOICE.getManueverCPSpent() > consideredCP) {
							consideredCP = MANUEVER_CHOICE.getManueverCPSpent();
						}
						///*
						if (consideredCP < Math.ceil(cp * .5)) {
							consideredCP = Math.ceil(cp * .5);
						}
						//*/
						B_BS_REQUIRED_DEFAULT =lastDefault;
				
						B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_1] =consideredCP;
						B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_1_ENEMY] =  cp2;
						cp -= consideredCP;			
		
						
						if (cp > 2 && ( getFBAttack(true, cp, stipulateRemaining, dtn, false, FLAG_USE_ALL_CP, 0.5 ) || getAdvantageGainCPOffensiveMove(true, cp, stipulateRemaining, dtn, FLAG_USE_ALL_CP, 0.5 )) ) {
							B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_2] =   MANUEVER_CHOICE.getManueverCPSpent();
							B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_2_ENEMY] = stipulateRemaining;
							return B_COMBO_EXCHANGE_BUDGET;
						}
					}
				case COMBO_AlphaDisarm:	
					setAlphaStrikeBudget(cp, cp2);
					if ( getDisarm(true, B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_1], cp2, dtn, FLAG_USE_ALL_CP , 0, PREFERED_DISARM_BS, false) ) {
						return B_COMBO_EXCHANGE_BUDGET;
					}
				case COMBO_AlphaHookStrike:
					if ( getHook(true, B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_1], cp2, dtn, FLAG_USE_ALL_CP , 0, PREFERED_HOOK_BS) ) {
						return B_COMBO_EXCHANGE_BUDGET;
					}
				case COMBO_AlphaStrike:
					if ( getFBAttack(true, B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_1], cp2, dtn, false, FLAG_USE_ALL_CP, 0) ) {
						return B_COMBO_EXCHANGE_BUDGET;
					}
				case COMBO_FeintStrike:
				case COMBO_DoubleAttack:
					
				case COMBO_SimulatenousBlockStrike:	
					
				case COMBO_CoupDeGrace:
					lastDefault = B_BS_REQUIRED_DMG_DEFAULT;
					B_BS_REQUIRED_DMG_DEFAULT += COUP_BS_MODIFIER;
					if (cp2 < getTargetAlphaStrikeCPThreshold() && getFavorableAttack(cp, cp2, dtn, true, FLAG_USE_ALL_CP, getCoupThreshold(cp2) ) ) {
						B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_2] =  0;
						B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_2_ENEMY] = BUDGET_SKIP;
						B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_1] = cp;
						B_COMBO_EXCHANGE_BUDGET[BUDGET_EXCHANGE_1_ENEMY] = cp2;
						B_BS_REQUIRED_DMG_DEFAULT = lastDefault;
						return B_COMBO_EXCHANGE_BUDGET;
					}
					B_BS_REQUIRED_DMG_DEFAULT = lastDefault;
			}
		}
		return null;
	}
	

	private static inline function tryFavoredElseBorderlineAttacks(cp:Int, cp2:Int, dtn:Int, heuristic:Bool, flags:Int):Bool {
		return getFavorableAttack(cp, cp2, dtn, heuristic, flags) || getAdvantageGainCPOffensiveMove(true, cp, cp2, dtn,flags) || getBorderlineAttack(cp, cp2, dtn,  heuristic, flags) || getAdvantageGainCPOffensiveMove(false, cp, cp2, dtn,flags);
	}
	
	/**
	 * 
	 * @param	combo
	 * @param	cp
	 * @param	cp2
	 * @param	threatManuever
	 * @param	hasInitiative
	 * @param	secondExchange
	 * @param   lastManuever	If it's a specific manuever combo that requires followup in second exchange
	 * @return
	 */
	private static function getComboAction(combo:Int, cp:Int, cp2:Int, threatManuever:AIManueverChoice=null, hasInitiative:Bool = true, secondExchange:Bool = false):Bool {
		var flags:Int = FLAG_USE_ALL_CP;// secondExchange ? FLAG_USE_ALL_CP : 0;
		var lastInt:Int;
		var result:Bool;
		var dtn:Int = getPredictedOpponentDTN();
		
		if (hasInitiative) {  // proceed with ideal combo after gaining/keeping initiative
			
			switch( combo) {
					// ai combos with initiative:
					// consider 2nd exchange...a disabling manuever, if regular damage attack not deemed favorable...
					case COMBO_PureMeanStrikes:	
						return  tryFavoredElseBorderlineAttacks(cp, cp2, dtn, true, flags);
					case COMBO_HeavyFirstStrikes:
						return 
						!secondExchange ?  getAForcefulInitiativeAttack(P_THRESHOLD_FAVORABLE, cp, cp2, dtn, true, true, 0)
						: tryFavoredElseBorderlineAttacks(cp, cp2, dtn, true, flags);
					case COMBO_AlphaDisarm:	
						if (!secondExchange) {
							// if opponent has 2 weapons, may not bother with disarming because the potential reward isn't really good
							return !CURRENT_OPPONENT.isDualWeilding() &&  getDisarm(true, cp, cp2, dtn, flags, 0, PREFERED_DISARM_BS, false);
						}
						else {
							return getFavorableAttack(cp, cp2, dtn,  true, flags) || getBorderlineAttack(cp, cp2, dtn,  true, flags) ||  getAdvantageGainCPOffensiveMove(false, cp, cp2, dtn,flags);
						}
					case COMBO_AlphaHookStrike:
						if (!secondExchange) {
							return getHook(true, cp, cp2, dtn, flags, 0, PREFERED_HOOK_BS);
						}
						else {
							return tryFavoredElseBorderlineAttacks(cp, cp2, dtn, true, flags);
						}
					case COMBO_AlphaStrike:
						if (!secondExchange) {
							return getFBAttack(true, cp, cp2, dtn, true, flags, 0);
						}
						else {
							return tryFavoredElseBorderlineAttacks(cp, cp2, dtn, true, flags);
						}
					case COMBO_FeintStrike:
						if (!secondExchange) {
							
						}
						else {
							return tryFavoredElseBorderlineAttacks(cp, cp2, dtn, true, flags);
						}
					case COMBO_DoubleAttack:
						if (!secondExchange) {
							
						}
						else {
							return tryFavoredElseBorderlineAttacks(cp, cp2, dtn, true, flags);
						}
					case COMBO_SimulatenousBlockStrike:
						if (!secondExchange) {
							
						}
						else {
							return tryFavoredElseBorderlineAttacks(cp, cp2, dtn, true, flags);
						}
					case COMBO_CoupDeGrace:
						lastInt = B_BS_REQUIRED_DMG_DEFAULT;
						B_BS_REQUIRED_DMG_DEFAULT += COUP_BS_MODIFIER;
						result =cp2 < getTargetAlphaStrikeCPThreshold() && getFavorableAttack(cp, cp2, dtn,  true, flags, getCoupThreshold(cp2) );
						B_BS_REQUIRED_DMG_DEFAULT = lastInt;
						return result;
					// ai combos without initiative:  This branch should only happen on second exchange!
					case COMBO_DefensiveFirst:
							return tryFavoredElseBorderlineAttacks(cp, cp2, dtn, true, flags);
					case COMBO_DefensiveBorderline:
							return tryFavoredElseBorderlineAttacks(cp, cp2, dtn, true, flags);
					case COMBO_SpecialDefFirst:
							return tryFavoredElseBorderlineAttacks(cp, cp2, dtn, true, flags);
					case COMBO_AlphaInitiativeStealer:
							return tryFavoredElseBorderlineAttacks(cp, cp2, dtn, true, flags);
					case COMBO_AlphaDisarmDef:
							return tryFavoredElseBorderlineAttacks(cp, cp2, dtn, true, flags);
					case COMBO_SimulatenousBlockStrikeStealer:
							return tryFavoredElseBorderlineAttacks(cp, cp2, dtn, true, flags);
								
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
					case COMBO_FeintStrike:
					case COMBO_DoubleAttack:
					case COMBO_SimulatenousBlockStrike:
					case COMBO_CoupDeGrace:
						// consider: stealing initiatiive "to finish what I started"
						
					case COMBO_DefensiveFirst:
						if (threatManuever != null) {
							if (!secondExchange) {
								lastInt =  getCheapestBorderlineAtkCost(cp, cp2 - threatManuever.manueverCP, dtn);
								if ( lastInt > 0 ) {
										cp -=  lastInt;
										return getFBDefense( true, cp, threatManuever.manueverCP, threatManuever.manueverTN, true, FLAG_USE_ALL_CP, 0 );
								}
							}
							
						}
						// Determine which of these manuevers are to be used as overwritable viables
						//getFavorableDefense(cp, threatManuever.manueverCP, threatManuever., true, false);  // if secondExchange, make sure still having remaining dice dice for at least borderline attack  for 2nd exchange in order to be viable
						// getRotaOrCounter   //  is it viable/availalble? use it instead
						// getBlockOpenAndStrike //  is it viable/availalble? use it instead
					case COMBO_DefensiveBorderline:
						if (threatManuever != null) {
							if (!secondExchange) {
								if (getFleeOrDefend(false, cp, cp2 - threatManuever.manueverCP, getPredictedOpponentATN(), false, FLAG_BORDERLINE_DEF_SAFETY|FLAG_GET_CHEAPEST, 0, true)) {
									cp -= MANUEVER_CHOICE.getManueverCPSpent();
									return getFBDefense( false, cp, threatManuever.manueverCP, threatManuever.manueverTN, true, FLAG_BORDERLINE_DEF_SAFETY, 0 );
								}
							}
							
						}
					case COMBO_SpecialDefFirst:
						if (threatManuever != null) {
							return getSpecialDefWithReturnAttack(cp, cp2, threatManuever.manueverCP, threatManuever.manueverTN, 0, secondExchange);
						}
					case COMBO_AlphaDisarmDef:
						if (threatManuever != null) {
							//if (!secondExchange) {
								return getDisarm(true, cp, threatManuever.manueverCP, threatManuever.manueverTN, 0, 0, PREFERED_DISARM_DEF_BS, true, threatManuever.offhand );
							//}
						}
					case COMBO_AlphaInitiativeStealer:
						
					
					case COMBO_SimulatenousBlockStrikeStealer:  // if rules allow so under TROS TFOB stealing inintiatiive peanlty to be able to do this
					
						
			}
		}
		return false;
	}
	
	@return("B_VIABLE_PROBABILITY_GET", "MANUEVER_CHOICE")
	@inspect([ { inspect: { display:"selector" }, choices:"COMBO" }, { inspect: { min:0 } }, { inspect: { min:0 }}  ]) 
	private static function getComboActionTest(combo:Int, cp:Int, cp2:Int, threatManuever:AIManueverChoice = null, hasInitiative:Bool = true, secondExchange:Bool = false):Bool {
		return getComboAction(combo, cp, cp2, threatManuever, hasInitiative, secondExchange) || ( hasInitiative ? tryBestPossibleAttackOrDefBoliao(cp, cp2, threatManuever, secondExchange) : tryBestPossibleDefenseBoliao(cp,cp2,threatManuever, secondExchange) );
	}
	
	
	
	
	static private function getCheapestBorderlineAtkCost(cp:Int, againstCP:Int, dtn:Int, customThreshold:Float=0):Int
	{
		var cpToSpend:Int = 0;
		 if ( getAdvantageGainCPOffensiveMove(false, cp, againstCP, dtn, FLAG_GET_CHEAPEST, customThreshold) ) {
			cpToSpend = MANUEVER_CHOICE.getManueverCPSpent();
		 }
		 
		 if ( getFBAttack(false, cp, againstCP, dtn, false, FLAG_GET_CHEAPEST, customThreshold ) ) {
			 if (MANUEVER_CHOICE.getManueverCPSpent() < cpToSpend) {
				cpToSpend = MANUEVER_CHOICE.getManueverCPSpent();
			 }
		 }
		 return cpToSpend;
	}
	
	private inline function isDualWeilding():Bool 
	{
		return (equipMasterhand != null && equipOffhand != null && WeaponSheet.weaponNameIsShield(equipOffhand) );
	}
	
	static private inline function getCoupThreshold(cp2:Int):Float
	{
		return cp2 >= 2 ? 0 : cp2 == 0 ? 0.00001 : 0.5;
	}
	
	
	private static inline function addPossibleComboManueverChoice(index:Int, theChoice:AIManueverChoice):Void {
		theChoice.copyTo( index >= B_COMBO_CANDIDATE_MANUEVER.length ? (B_COMBO_CANDIDATE_MANUEVER[index] = new AIManueverChoice()) : B_COMBO_CANDIDATE_MANUEVER[index] );
	}
	
	

	private static inline var BUDGET_SKIP:Int = -1;
	private static var MANUEVER_CHOICE_CONSIDER_MASTER:AIManueverChoice = new AIManueverChoice();


	
	
	/**
	 * 
	 * @param	cp
	 * @param	cp2
	 * @param	threatManuever
	 * @return
	 */
	private static function setBestComboActionWithInitiativePlan(cp:Int, cp2:Int, threatManuever:AIManueverChoice=null):Bool {
		
		B_COMBO_CANDIDATE_COUNT = 0;
		
		
		if ( CURRENT_OPPONENT.initiative)  {
			// considerations in a double-red situation..
			if (threatManuever != null && threatManuever.manueverType == AIManueverChoice.TYPE_ATTACKING  ) {
				// with known enemy attack manuever declared
			}
		}
		var budget:Vector<Int>;
		
		for (i in COMBOS_LEN_INITIATIVE...COMBOS_LEN_INITIATIVE_FINAL) {
			budget = getComboExchangeBudgetingWithInitiative(i, cp, cp2, threatManuever);
			if (budget != null) {
				if ( getComboAction(i, budget[BUDGET_EXCHANGE_1], budget[BUDGET_EXCHANGE_1_ENEMY], threatManuever, true, false) ) {
					MANUEVER_CHOICE.copyTo( MANUEVER_CHOICE_CONSIDER_MASTER);
					if ( budget[BUDGET_EXCHANGE_2_ENEMY] == BUDGET_SKIP || getComboAction(i, budget[BUDGET_EXCHANGE_2], budget[BUDGET_EXCHANGE_2_ENEMY], threatManuever, true, true) ) {	
						MANUEVER_COMBO_SET = i;
						MANUEVER_CHOICE_SET = MANUEVER_CHOICE_CONSIDER_MASTER;
						return true;
					}
				}
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
		
		var probabilityCheck:Float;
		var len:Int = COMBOS_LEN_INITIATIVE;
		while (i < COMBOS_LEN_INITIATIVE) {
			budget = getComboExchangeBudgetingWithInitiative(i, cp, cp2, threatManuever);
			if (budget != null) {
				if ( getComboAction(i, budget[BUDGET_EXCHANGE_1], budget[BUDGET_EXCHANGE_1_ENEMY], threatManuever, true, false) ) {
					probabilityCheck = B_VIABLE_PROBABILITY_GET;
					MANUEVER_CHOICE.copyTo( MANUEVER_CHOICE_1);
					if ( budget[BUDGET_EXCHANGE_2_ENEMY] == BUDGET_SKIP || getComboAction(i, budget[BUDGET_EXCHANGE_2], budget[BUDGET_EXCHANGE_2_ENEMY], threatManuever, true, true) ) {	
						//probabilityCheck  += B_VIABLE_PROBABILITY_GET;
						//if (probabilityCheck >= curProbability ) {
							//if (probabilityCheck != curProbability) B_COMBO_CANDIDATE_COUNT  = 0;	
							B_COMBO_CANDIDATES[B_COMBO_CANDIDATE_COUNT] = i;
							addPossibleComboManueverChoice(B_COMBO_CANDIDATE_COUNT, MANUEVER_CHOICE_1);
							curProbability = probabilityCheck;
							B_COMBO_CANDIDATE_COUNT++;
						//}
						
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
	@return("MANUEVER_COMBO_SET", "MANUEVER_CHOICE_SET", "B_COMBO_CANDIDATE_COUNT", "B_COMBO_CANDIDATES")
	@inspect([  { inspect:{min:0} }, { inspect:{min:0} } ]) 
	private static function setBestComboActionWithInitiativePlanTest(cp:Int, cp2:Int, threatManuever:AIManueverChoice = null):Bool {
		if ( setBestComboActionWithInitiativePlan(cp, cp2, threatManuever) ) {
			return true;
		}
		else {
			if (tryBestPossibleAttackOrDefBoliao(cp, cp2, threatManuever, false)) {
				MANUEVER_CHOICE.copyTo( MANUEVER_CHOICE_SET);
				return true;
			}
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
	public static function setBestComboActionWithoutInitiativePlan(cp:Int, cp2:Int, threatManuever:AIManueverChoice):Bool {
		
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
				MANUEVER_CHOICE.copyTo( MANUEVER_CHOICE_1);
				//if ( probabilityCheck >= curProbability) {
					//if (probabilityCheck != curProbability) B_COMBO_CANDIDATE_COUNT  = 0;
					B_COMBO_CANDIDATES[B_COMBO_CANDIDATE_COUNT] = -i;
					addPossibleComboManueverChoice(B_COMBO_CANDIDATE_COUNT, MANUEVER_CHOICE_1);
					curProbability = probabilityCheck;
					B_COMBO_CANDIDATE_COUNT++;
				//}
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
	
	@return("MANUEVER_COMBO_SET", "MANUEVER_CHOICE_SET", "B_COMBO_CANDIDATE_COUNT", "B_COMBO_CANDIDATES")
	@inspect([  { inspect:{min:0} }, { inspect:{min:0} } ]) 
	public static function setBestComboActionWithoutInitiativePlanTest(cp:Int, cp2:Int, threatManuever:AIManueverChoice):Bool {
		if ( setBestComboActionWithoutInitiativePlan(cp, cp2, threatManuever) ) {
			return true;
		}
		else {
			if ( tryBestPossibleDefenseBoliao(cp, cp2, threatManuever, false)) {
				MANUEVER_CHOICE.copyTo( MANUEVER_CHOICE_SET );
				return true;
			}
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
		if (initiative) {
			return tryBestPossibleAttackOrDefBoliao(cp, opponent.cp, threatManuever, currentExchange == 2);
		}
		else {
			return tryBestPossibleDefenseBoliao(cp, opponent.cp, threatManuever, currentExchange == 2);
		}
		
		return false;
	}
	
	
	
	
}