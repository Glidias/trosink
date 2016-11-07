package troshx.components;
import troshx.core.Manuever;
import troshx.util.LibUtil;
import troshx.util.StringHashId;

/**
 * Bare bones component state class for FightState per entity
 * @author Glidias
 */
typedef ManueverDeclare = {

	// results dumped here, not ideal, but ah well..
	@:optional var marginSuccess:Int;
	@:optional var reflexScore:Float;
	@:optional var successes:Int;

	// manuever declare properties
	var manuever:Manuever;
	var numDice:Int;
	@:optional var from:FightState;
	@:optional var tn:Int;
	@:optional var to:FightState;
	@:optional var targetZone:Int;
	@:optional var cost:Int;
	@:optional var defManuever:Manuever;
	
}


class FightState
{
	// instance schedule 
	public var s:Int = 0;  // the current step within the exchange
	public var e:Bool = false;  // false for exchange 1/2, true for exchange 2/2
	
	// side affiliiation..hmm
	public var side:Int = 1;
	
	#if ref_required
	var _refId:String = StringHashId.get();
	#end

	
	// riddle stuff here
	public var numEnemies:Int = 0;
	public var initiative:Bool = false;  //  initaitive  flag. 
	
	
	var target__:FightState = null;
	@ref public var target(get, set):FightState; 
	public #if !ref_required inline #end function get_target():FightState 
	{
		return target__;
	}
	public #if !ref_required inline #end function set_target(value:FightState):FightState 
	{
		return target__ = value;
	}
	
	
	public var targetLocked:Bool = false;  // flag to indicate fighter cannot change target..

	
	
	public var paused(get, null):Bool;
	function get_paused():Bool 
	{
			// no target heuristic...or if you have target, determine if target is a mututal opponent, and if so, same initiative need to re-roll
		// else continue fighting against your target
		return target == null ? (targetedByFlags == 0) : (target.target ==  this && !target.initiative && !initiative) || (target.target != this && !initiative && traceExceptionIsPaused());
	}
	public var targetedByFlags:Int = 0;	
	public var flags:Int = 0;
	
	
	public function traceExceptionIsPaused():Bool {
		//throw new Error("Exception found");
		trace( "traceExceptionIsPaused exception found");
		return true;
	}
	
	// Fightstate initiative values
	// values higher than zero indicate the possibility to perform actions with some form of Initiative (clear initiative or contesting for it)
	public static inline var GOT_INITIATIVE:Int = 2;  // fighter has initiative (this also imples that the target lacks initiative)
	public static inline var CONTESTING_INITIATIVE:Int = 1;  // both fighters have mutual initiative, or 1 side or both is forced to contest for it during the Action itself
	public static inline var NO_INITIATIVE:Int = 0;  // fighter has no initiative
	public static inline var REROLL_INITIATIVE:Int = -1;  // both fighters have no mutual initiative, and must re-roll for it in the next round via orientation.
	public static inline var UNCERTAIN_INITATIVE:Int = -10; // both sides have uncertain initiative, but will determine it after targets are determined (if required) and before the action starts
	public static inline var UNCERTAIN_INITIATIVE_RESOLVED:Int = 10;
	
	// Fight state orientation values  
	public static inline var ORIENTATION_NONE:Int = 0; 	// a value of zero indicates no orientation selected, and this also happens after the first manuever is resolved at the start of a bout of after a Pause.
	public static inline var ORIENTATION_DEFENSIVE:Int = 1;
	public static inline var ORIENTATION_CAUTIOUS:Int = 2;
	public static inline var ORIENTATION_AGGRESSIVE:Int = 3;
	public var orientation:Int = 0;  // warning, this is used as an implicit multiplier for determining orientation initaitive (higher value higher targeting initiative..)
	public static var ORIENTATION_STRINGS:Array<String> = ["None", "Defensive", "Cautious", "Aggressive"];

	
	public function hasOrientationInitiative(targetFight:FightState):Bool {
		return orientation == ORIENTATION_AGGRESSIVE || (orientation != ORIENTATION_DEFENSIVE && ( (this.target==targetFight && targetFight.target !=this) || orientation > targetFight.orientation) );
	}
	
	public function getInitiativeTowards(fightState:FightState):Int {
		
		if (orientation == 0 ) {   // legacy code  //|| s >=2 
			return initiative ? fightState.initiative ? CONTESTING_INITIATIVE :  GOT_INITIATIVE   
			:  NO_INITIATIVE;
		}
		else {  // orientation selected, need to determine
			if (orientation != ORIENTATION_DEFENSIVE) {
				// either cautious or aggressive, which means can attack
				if (orientation != fightState.orientation ) {  // aggressive over cautious, or aggressive/cautious over defensive/no-orientation, vice versa
					return orientation > fightState.orientation ? GOT_INITIATIVE : NO_INITIATIVE;
				}
				else {  // cautious vs cautious, or aggressive vs aggressive 
					if (orientation == ORIENTATION_CAUTIOUS) {
						if (fightState.orientation != ORIENTATION_CAUTIOUS)  throw "Equal assertion cautious failed:"+fightState.orientation;
						return initiative != fightState.initiative ? UNCERTAIN_INITIATIVE_RESOLVED : UNCERTAIN_INITATIVE;
					}
					else if (orientation == ORIENTATION_AGGRESSIVE) {
						if (fightState.orientation != ORIENTATION_AGGRESSIVE)  throw "Equal assertion aggressive failed:"+fightState.orientation;
						return CONTESTING_INITIATIVE;
					}
					else {
						throw "Missed out this case?? Orientation: " + orientation;
					}
				}
			}
			else {  // defensive, can never attack for this exchange...so absolutely no intiative
				return NO_INITIATIVE;
			}
		}
	}
	
	// Declared manuevers info
	//public var manuever:int = -1;  // primary manuever index (declared move) for the current turn
	private var manuevers:Array<ManueverDeclare> = [ { manuever: null, numDice:0 } ]; // for composite/multiple manuevers within the stack
	private var enemyManuevers:Array<ManueverDeclare> = [];  // any detected enemy manuevers made against you...
	
	// The state of the fight
	public var rounds:Int = 0;
	public var attacking:Bool = false;  // flag to indicate whether is forced/confimed attacking on current turn roll
	public var shortRangeAdvantage:Bool = false;  // <- this would be different later...
	public var lastAttacking:Bool = false; // flag to indicate if was attacking on last declared move
	public var combatPool:Int;
	public var shock:Int;
	

	
	
	public function resetManueverObj(obj:ManueverDeclare):Void {
		obj.manuever = null;
		obj.marginSuccess = null;
		obj.reflexScore = null;
		obj.successes = null;
		obj.numDice = 0;
		obj.from = null;
		obj.tn = 0;
		obj.to = null;
		obj.targetZone = null;
		obj.cost = null;
		obj.defManuever = null;
	}
	
	public function resetManuevers():Void {
		var primary:Dynamic = manuevers[0];
		resetManueverObj(primary);
		LibUtil.truncateArray(manuevers, 1); //manuevers.length = 1;
		LibUtil.clearArray(enemyManuevers);
	}
	
	public function syncStepWith(fight:FightState):Void {
		if (fight.s >=  s) {  
			s = fight.s;
		}
		else {
			fight.s = s;
		}
	}
	
	public inline function isSyncedWith(fight:FightState):Bool {
		return s == fight.s && e == fight.e;
	}
	
	public function step(nextExchange:Bool):Void {
			shock = 0;
		//	lostInitiative = false;
			targetLocked = false;
			s++;
			if (nextExchange) {  //s >= 3
				s = 0;
				e = !e;
				s = 0;
				orientation = 0;// FightState.ORIENTATION_NONE;
				if (!e) {
					rounds++;
				}
			}
		
	}
	
	public function clone():FightState {
		var fState:FightState = new FightState();
		fState.side = side;
		return fState;
	}
	
	public static function isAttackingChoice(choice:ManueverDeclare):Bool {
		return choice.manuever!=null && choice.manuever.type == Manuever.TYPE_OFFENSIVE;
	}
	
	public function checkContestAgainstDefense(defManueverChoice:ManueverDeclare):Bool 
	{
		var primary:ManueverDeclare = getPrimaryManuever();
		var secondary:ManueverDeclare = getSecondaryManuever();
		return (isAttackingChoice(primary) && primary.to == defManueverChoice.from) || (secondary != null && isAttackingChoice(secondary) && secondary.to == defManueverChoice.from);
	}
	
	
	static public function manueverNeedsElaboration(cManuever:ManueverDeclare):Bool 
	{
		return cManuever.numDice == 0 || (cManuever.to != null ? cManuever.targetZone == null : false);
	}
	
	public inline function getPrimaryManuever():ManueverDeclare 
	{
		return manuevers[0];
	}
	public inline function getSecondaryManuever():ManueverDeclare 
	{
		return manuevers.length > 1 ? manuevers[1] : null;
	}
	public inline function getPrimaryEnemyManuever():ManueverDeclare   
	{
		return enemyManuevers.length > 0 ? enemyManuevers[0] : null;
	}
	
	public inline function getEnemyManueverAt(index:Int):ManueverDeclare {
		return enemyManuevers[index];
	}
	public inline function getManueverAt(index:Int):ManueverDeclare 
	{
		return manuevers[index];
	}
	
	public inline function isUnderAttack():Bool 
	{
		return enemyManuevers.length > 0;
	}
	
	public inline function getTotalEnemyManuevers():Int 
	{
		return enemyManuevers.length;
	}
	
	public inline function noMoreCP():Bool 
	{
		return combatPool <= 0;
	}
	
	public function setSideAggro(val:Int):FightState {
		side = val;
		return this;
	}
	
	
	public function hostileTowards(fight:FightState):Bool {
		return this.side != fight.side;
	}
	
	public inline function matchScheduleWith(other:FightState):Void {
		s = other.s;
		e = other.e;
	}
	
	// this happens after a successful full disengagement, or during a battle exchange pause
	public function reset(disengaged:Bool = false):FightState {
		// battle exchange pause
		s = 0;  
		e = false;
		orientation = 0;
		initiative = false;
//		lastHadInitiative = true;
		
		targetLocked = false;
		
		attacking = false;
		lastAttacking = false;
		shortRangeAdvantage = false;
	//	paused = true;
		shock = 0;
		//lostInitiative = false;
		//lostInitiativeTo = new Dictionary();
		
		if (disengaged) {  // full disengagement
			numEnemies = 0;
			
			flags = 0;
			targetedByFlags = 0;
			target  = null;
			rounds = 0;
			//bumping = false;
//			lastHadInitiative = true;
			resetManuevers();
		}
		return this;
	}
	
	
	public function new() 
	{
	
	}
	
	
	


	
}