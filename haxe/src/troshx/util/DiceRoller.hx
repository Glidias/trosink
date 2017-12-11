package troshx.util;

/**
 * ...
 * @author Glidias
 */

typedef DiceRollResults = {
	var successes:Int;
	var mayBotch:Bool;  // lol can't remember what this meant
}

class DiceRoller
{

	private static var NUM_ONES:Int = 0;
	public static var LAST_ROLL_SUCCESSES:Int = 0;
	
	public static function getRollNumSuccesses(amountDice:Int, tn:Int):Int {
		var result:Int;
		NUM_ONES = 0;
		var i:Int = amountDice;
		var numSuccesses:Int = 0;
		var numStacks:Int = 0;
		while (--i > -1) {
			result = (Std.int(Math.random() * 10) + 1);
			if (result == 1) NUM_ONES++;
			numSuccesses += result >= tn ? 1 : 0;
			numStacks += tn > 10 && result == 10 ? 1 : 0;
		}
		
		
		if (numStacks > 0) {  // this method only supports tn MAX 20!
			i = numStacks;
			while (--i > -1) {
				result = (Std.int(Math.random() * 10) + 1);
				numSuccesses += result >= tn-10 ? 1 : 0;
			}
		}
		
		LAST_ROLL_SUCCESSES = numSuccesses;
		return numSuccesses;
	}
	
	public static inline var ROLL_RESULT_BOTCH:Int = -2;
	public static inline var  ROLL_RESULT_DRAW:Int = 0;
	public static inline var ROLL_RESULT_FAILED:Int = -1;

	public static function makeChallengeRoll(amountDice:Int, tn:Int, requiredSuccesses:Int):Int {
		var numSuccesses:Int =  getRollNumSuccesses(amountDice, tn);
		return numSuccesses >= requiredSuccesses ? numSuccesses - requiredSuccesses : NUM_ONES >= (amountDice > 1 ? 2 : 1) ? ROLL_RESULT_BOTCH : ROLL_RESULT_FAILED;
	}
	
	public static function makeIndividualRoll(amountDice:Int, tn:Int, tarObject:DiceRollResults = null):DiceRollResults {
		tarObject = tarObject != null ? tarObject : { successes:0, mayBotch:false };
		var num:Int = getRollNumSuccesses(amountDice, tn);
		tarObject.successes = num;
		tarObject.mayBotch =  NUM_ONES >= (amountDice > 1 ? 2 : 1);
		return tarObject; 
	}
	
}