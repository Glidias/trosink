package troshx.util;
import troshx.tros.ai.TROSAiBot;

/**
 * AI utility module for handling calculations/automating strategies. Can also reflect probability judgements to player. Also may contain alternative roll methods.
 * @author Glenn Ko
 */

@:expose
@:rtti
class TROSAI
{

	
	public function new() 
	{
		
	}
	
	/**
	 * The ! function on your calculator
	 * @param	val
	 * @return
	 */
	public static inline function factorial(val:Int):Float {
		if (val == 0) val = 1;
		var v:Int = val;
		while( --v > 1) {
			val*=v;
		}
		return val;
	}

	/**
	 *  The nCr functino on your calculator
	 * @param	n	The total no. of samples
	 * @param	r	The number of samples to choose from the total no. of samples
	 */
	public static inline function binomialCoef(n:Int, r:Int):Float {
		return r > 0 ? factorial(n) / (factorial(r) * factorial(n - r)) : 1;
	}
	
	/**
	 * Aggregates probability of a success of a given die of TN >=1. Can be used as a quick computational/alternative way of determining dice roll success 
	 * (especially when it comes to stacking TNs higher than 10..., this method acts as a constant O(1) performance shortcut)
	 * @param	tn	Given TN must be >=1
	 * @return	Probabiliy of success of a given die of TN
	 */
	public static inline function getTNSuccessProbForDie(tn:Int):Float {
		return tn < 11 ? (10-tn+1) / 10 :  ( 1- ( tn - Math.floor((tn)/10)*10 ) / 10 )   *  Math.pow(0.1, Math.floor(tn/10) );
	}
	
	public static inline function getXSuccessesProb(numDiceToRoll:Int, tn:Int, x:Int):Float {
		var prob:Float = getTNSuccessProbForDie(tn);
		return binomialCoef(numDiceToRoll, x) * Math.pow(prob, x) * Math.pow(1 - prob, numDiceToRoll-x);
	}
	
	public static function getAtLeastXSuccessesProb(numDiceToRoll:Int, tn:Int, x:Int):Float {
		var accum:Float = 0;
		while( x <= numDiceToRoll) {
			accum += getXSuccessesProb(numDiceToRoll, tn, x);
			x++;
		}
		if (accum > 1) accum  = 1; // clamp floating point addition inaccruacies
		return accum;
	}
	
	public static inline function probabilityAOrB(a:Float, b:Float):Float {
		return (a + b) - (a * b);
	}
	
	public static inline function probabilityOfArrayOr(arr:Array<Float>):Float {
		var p:Float = 0;
		if (arr.length == 0) return 0;
		p = arr[0];
		for (i in 1...arr.length) {
			p  = probabilityAOrB(p, arr[i]);
		}
		return p;
	}
	
	public static function getBelowOrEqualXSuccessesProb(numDiceToRoll:Int, tn:Int, x:Int):Float {
		var accum:Float = 0;
		while( x >=0 ) {
			accum += getXSuccessesProb(numDiceToRoll, tn, x);
			x--;
		}
		if (accum > 1) accum  = 1; // clamp floating point addition inaccruacies
		return accum;
	}
	
	//public static function 
	
	/**
	 * 
	 * Determine chance to succeed in contested roll, given a minimum required TS (total success) of 1 die.
	 * @param	numDice	your dice pool to roll
	 * @param	tn	your TN
	 * @param	againstNumDice 	enemy dice pool to roll
	 * @param	againstTN	enemy TN
	 * @param	rs 	The margin of success required to be determined as a "Success" (defaulted to 1 if left undefined)
	 * @return
	 */
	public static function getChanceToSucceedContest(numDice:Int, tn:Int, againstNumDice:Int, againstTN:Int,  rs:Int = 1, requireAtLeast1TS:Bool=true):Float {
		// rolled 
		if (rs > numDice) {
			//trace("Exiting..." + numDice + ", " + rs + " ::"+(rs>numDice) + ", "+Type.typeof(numDice) + ", "+Type.typeof(rs));
			return 0;
		}
		var accum:Float = 0;
		var start:Int = requireAtLeast1TS && rs < 1 ? 1 : rs;
		var i = start;
		var p:Float = 0;
		
		//trace("CAULATING");
		while (i <= numDice) {
			
			var k = i -rs;
			if (k > againstNumDice) {
				k = againstNumDice;
			}
			
			while ( k >= 0) {
				//trace("add:" + i + " vs "+k);
				p += getXSuccessesProb(numDice, tn, i) * getXSuccessesProb(againstNumDice, againstTN, k);
				k--;
			}
			i++;
		}
		return p;
	}
	

	
	/**
	 * 
	 * @param	numDice  your dice pool to roll
	 * @param	tn  your TN
	 * @param	rs  The margin of success required to be determined as a "Success" (defaulted to 1 if left undefined)
	 */
	public static function getChanceToSucceed(numDice:Int, tn:Int, rs:Int = 1):Float {
		if (rs > numDice) return 0;
		return getAtLeastXSuccessesProb(numDice, tn, rs);
	}
	
	// Display array outputs
	
	public static function getAllXSuccessesProb(numDice:Int, tn:Int):Array<Float> {
		var arr:Array<Float> = [];
		for (i in 0...(numDice + 1)) {
			arr.push(getXSuccessesProb(numDice, tn, i));
		}
		return arr;
	}
	
	public static function getTabulatedRollData(numDice:Int, tn:Int):Array<Dynamic> {
		var arr:Array<Dynamic> = [];
		var accum:Float = 0;
		var i:Int = numDice;
		while (i >= 0) {
			var v:Float = getXSuccessesProb(numDice, tn, i);
			//v =  v > 1 ? 1 : v;
			
			accum += v;
			arr.push({ x:i, gte:accum, eq:v });
			i--;
		}
		arr.reverse();
		for (i in 0...(arr.length-1)) {
			if (arr[i + 1].eq <= arr[i].eq) {
				arr[i].peak = 1;
				if (arr[i + 1].eq != arr[i].eq) break;
			}
		}
		return arr;
	}
	
	// math display functions
	inline public static function maxPrecision(x:Float, precision:Int):Float
	{
		return roundTo(x, Math.pow(10, -precision));
	}
	 public static function roundTo(x:Float, y:Float):Float
	{
		#if js
		return Math.round(x / y) * y;
		#elseif flash
		var t:Float = untyped __global__["Math"].round((x / y));
		return t * y;
		#else
		var t = x / y;
		if (t < INT32_MAX && t > INT32_MIN)
			return Math.round(t) * y;
		else
		{
			t = (t > 0 ? t + .5 : (t < 0 ? t - .5 : t));
			return (t - t % 1) * y;
		}
		#end
	}
	
	inline public static var INT32_MIN =
	#if cpp
	//warning: this decimal constant is unsigned only in ISO C90
	-0x7fffffff;
	#else
	0x80000000;
	#end
	
	/**
	 * Max value, signed integer.
	 */
	inline public static var INT32_MAX = 0x7fffffff;
	
	
	public static inline function displayAsPercentage(probability:Float):Float {
		probability *= 100;
		return probability < 1 && probability > 0 ? maxPrecision(probability,2) : Math.floor(probability);
	}
}


@:rtti
@:expose
class AIManueverChoice {
	@inspect public var manuever:String;
	@inspect({min:0}) public var manueverCP:Int; 
	@inspect({min:0}) public var manueverTN:Int;
	@inspect({min:0}) public var targetZone:Int;
	@inspect({display:"selector"}) @choices("TYPE")  public var manueverType:Int;
	@inspect public var offhand:Bool;
	@inspect public var againstID:Int;
	@inspect({min:0}) public var cost:Int;
	
	public inline function getManueverCPSpent():Int {
		return cost + manueverCP;
	}
	
	public static inline var TYPE_ATTACKING:Int =2;
	public static inline var TYPE_DEFENDING:Int = 1;
	
	public static inline var TARGET_WEAPON:Int = 0;
	public static inline var TARGET_SHIELD:Int  = 1;
	
	public function new() 
	{
		
	}
	
	public inline function nothing():Void {
		manuever = "";
		manueverCP = 0;
		targetZone = 0;
		manueverType  = 0;
		offhand = false;
		againstID = 0;
	}
	
	public inline function copyTo(newChoice:AIManueverChoice, newAgainstID:Int=-1):Void {
		newChoice.manuever = manuever;
		newChoice.manueverCP = manueverCP;
		newChoice.targetZone = targetZone;
		newChoice.manueverType = manueverType;
		newChoice.offhand = offhand;
		newChoice.manueverTN = manueverTN;
		newChoice.againstID = newAgainstID  >= 0 ? newAgainstID : againstID;

	}
	
	public function setAttack(manuever:String, manueverCP:Int, manueverTN:Int, targetZone:Int, cost:Int, offhand:Bool=false):Void {
		this.manuever = manuever;
		this.manueverCP = manueverCP;
		this.targetZone  = targetZone;
		this.offhand = offhand;
		this.manueverType = TYPE_ATTACKING;
		this.manueverTN = manueverTN;
		this.cost = cost;
	}
	
	public function setDefend(manuever:String, manueverCP:Int, manueverTN:Int, cost:Int, offhand:Bool=false):Void {
		this.manuever = manuever;
		this.manueverCP = manueverCP;
		this.targetZone  = 0;
		this.offhand = offhand;
		this.manueverType = TYPE_DEFENDING;
		this.manueverTN = manueverTN;
		this.cost = cost;
	}
}

