package troshx.core;

/**
 * Generic common/game rules for TROS-like games
 * @author Glidias
 */

@:expose
@:rtti
class GameRules
{
	// is there a CP limit cap for spending on Flee/Full Evasion manuevers?
	public static inline var FLEE_CAP_NONE:Int = 0;
	public static inline var FLEE_CAP_BY_MOBILITY_EXCHANGE1:Int = 1;
	public static inline var FLEE_CAP_BY_MOBILITY_ALL:Int = 2;

	@inspect({display:"selector"}) @choices("FLEE_CAP") public static var FLEE_CAP:Int = FLEE_CAP_NONE;
	
}