package troshx.sos.core;
import troshx.core.IUid;
import troshx.ds.IUpdateWith;
import troshx.sos.bnb.IBuildUIFields;
import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.core.BoonBane.BoonBaneAssign;
import troshx.sos.sheets.CharSheet;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.Modifier.EventModifierBinding;
import troshx.sos.core.Modifier.SituationalCharModifier;
import troshx.sos.core.Modifier.StaticModifier;

/**
 * A Boon or Bane for the purpose of recording in Character sheet
 * @author Glidias
 */
class BoonBane 
{
	public var isBane(default,null):Bool;
	public var name(default, null):String;
	public var flags(default, null):Int;
	public var clampRank(default, null):Bool;
	public var costs(default, null):Array<Int>;
	public var multipleTimes(default, null):Int;
	public var channels(default, null):Int;
	public var superChannels(default, null):Int;
	
	// these modifiers are for returning a specific value for hardcoded cases
	public var staticModifiers(default, null):Array<StaticModifier>;
	public var situationalModifiers(default, null):Array<SituationalCharModifier>;
	
	// these modifiers are only triggered upon events
	public var eventBasedModifiers(default, null):Array<EventModifierBinding>;
	
	public var customCostInnerSlashes(default, null):String;
	
	public var conditions(default, null):Array<CharSheet->Int->Bool>;
	
	@:channel public static inline var __GOOD_EYES__BAD_EYES:Int = (1 << 0);
	@:channel public static inline var __GOOD_EARS_BAD_EARS:Int = (1 << 1);
	@:channel public static inline var __GOOD_EARS_BAD_NOSE:Int = (1 << 2);
	@:channel public static inline var __RICH__POOR:Int = (1 << 3);
	@:channel public static inline var __TRUE_GRIT_SHELTERED:Int = (1 << 4);
	@:channel public static inline var __ROBUST_FRAIL:Int = (1 << 5);
	@:channel public static inline var __ONE_EYED:Int = (1 << 6);
	@:channel public static inline var __CRAVEN__HONORABLE:Int = (1 << 7);
	@:channel public static inline var __HONORABLE__COMPLETE_MONSTER:Int = (1 << 8);
	@:channel public static inline var __TALL__SHORT:Int = (1 << 9);
	
	@:flag public static inline var CHARACTER_CREATION_ONLY:Int = (1 << 0);
	@:flag public static inline var CANNOT_BE_REMOVED:Int = (1 << 1);
	
	public inline function isAvailableCharaterCreation():Bool {
		return this.costs != null;
	}
	
	public static inline var TIMES_INFINITE:Int = -1;
	public static inline var TIMES_VARYING:Int = -2;
	
	public var uid(get, never):String;
	inline function get_uid():String 
	{
		return name;
	}
	
	public function new(name:String, costs:Array<Int>) 
	{
		this.name = name;
		this.costs = costs;
		this.flags = 0;
		this.clampRank = false;
		this.multipleTimes = 0;
		this.channels = 0;
		this.superChannels = 0;
	}

	
}

class Boon extends BoonBane {
	public function new(name:String, costs:Array<Int>) {
		super(name, costs);
	}
	
	function getEmptyAssignInstance(char:CharSheet):BoonAssign {
		return new BoonAssign();
	}
	
	public function getAssign(rank:Int, char:CharSheet):BoonAssign {
		var me:BoonAssign = getEmptyAssignInstance(char);
		me.boon = this;
		me.rank = rank;
		//if ( boon.costs != null) me._costCached = boon.costs[(rank >= 1 ? rank - 1 : 0];  // for reference only
		return me;
	}
	
}


class Bane extends BoonBane  {
	public function new(name:String, costs:Array<Int>) {
		super(name, costs);
		isBane = true;
	}
	
	function getEmptyAssignInstance(char:CharSheet):BaneAssign {
		return new BaneAssign();
	}
	
	public function getAssign(rank:Int, char:CharSheet):BaneAssign {
		var me:BaneAssign =  getEmptyAssignInstance(char);
		me.bane = this;
		me.rank = rank;
		//if ( bane.costs != null) me._costCached = boon.costs[(rank >= 1 ? rank - 1 : 0]; // for reference only
		return me;
	}
	
	
}



class BoonBaneAssign implements IBuildUIFields implements IUid 
{
	public var rank:Int;
	//public var qty:Int;
	
	public var discount:Int = 0;
	
	public var _costCached:Int;  // used internally by engine to calculate cached costs of boons/banes. Do not touch!
	
	//public var ingame:Bool = false;
	public var _forcePermanent:Bool = false;
	public var _canceled:Bool = false;
	public var _minRequired:Int = 0;
	
	public function freeze():Void {
		
	}
	public function unfreezeAll():Void {
		
	}
	
	public var situationalModifiers(default, null):Array<SituationalCharModifier>;
	public var eventBasedModifiers:Array<EventModifierBinding>;
	
	public inline function dontCountCost():Bool {
		return _canceled || _forcePermanent;
	}
	
	public function cleanup():Void {
		
	}
	public function cleanupUIArrays():Void { // override by macro if needed, boilerplate run to auto-cleanup array after char is confirmed
		
	}
	
	// ingame only
	public function onFurtherAdded(char:CharSheet):Void {
		
	}
	public function onRemoved(char:CharSheet):Void {
		
	}
	public function onInited(char:CharSheet):Void {
		
	}
	
	public function getQty():Int {	// override this to reflect a different qty depending on Boon/Bane situation.
		return 1;
	}
	

	public function getCost(rank:Int):Int {
		return 0;
	}
	
	public inline function getCosting(bb:BoonBane, rank:Int):Int {
		return bb.costs[rank-1];  // assumed assigned rank is always > 0, else this method should NOT be called
	}
	
	public function isValid():Bool {	// mainly used as validation check for Character creation forms
		return true;
	}
	
	public function getBoonOrBane():BoonBane {
		return null;
	}
	
	
	public function getUIFields():Array<Dynamic> {
		return null;
	}
	

	
	/* INTERFACE troshx.core.IUid */
	
	public var uid(get, never):String;
	
	function get_uid():String 
	{
		return "";
	}

}

class BoonAssign extends BoonBaneAssign implements IUpdateWith<BoonAssign>
{
	public var boon:Boon;
	
	public function new() {
		
	}
	
	// utility

	inline function getMaxLength(costBase:Int, curLength:Int):Int {
		return Std.int((_remainingCached + curLength*costBase ) / costBase);
	}
	inline function clampLength(length:Int, minClamp:Int = 1 ):Int {
		return length >= minClamp ? length : minClamp;
	}
	inline function bitmaskIndexCanBeToggledAtCost(index:Int, value:Int, cost:Int):Bool {
		var curChecked:Bool = (value & (1 << index)) != 0;
		var b =  _remainingCached >= cost;
		return curChecked || b;
	}
	
	
	// used internally by engine to imperatively update available points for this assignment (excluding cost of current assignment)
	public var _remainingCached:Int; 
	public inline function updateRemainingCache(totalRemaining:Int):Void {
		_remainingCached = totalRemaining;
		//_remainingCached = totalRemaining + ( rank >=  1 ?  Std.int(Math.max( getCost(rank), boon.costs[0])) : 0  );
	}
	
	
	override public function get_uid():String {
		return boon.uid;
	}
	
	override public function getCost(rank:Int):Int {
		return getCosting(boon, rank < 2 ? 1 : rank);
	}
	public inline function getBaseCost(rank:Int):Int {
		return getCosting(boon, rank < 2 ? 1  : rank);
	}
	
	override public function getBoonOrBane():BoonBane {
		return boon;
	}
	
	override public function getUIFields():Array<Dynamic> {
		return null;
	}
	
	public function toString():String {
		return "[BoonAssign: " + boon.uid + "]";
	}
	
	
	/* INTERFACE troshx.ds.IUpdateWith.IUpdateWith<W> */
	
	public function updateAgainst(ref:BoonAssign):Void 
	{
		
	}
	
	public function spliceAgainst(ref:BoonAssign):Int 
	{
		return 0;
	}
	
}

class BaneAssign extends BoonBaneAssign implements IUpdateWith<BaneAssign>
{

	public var bane:Bane;
	public static inline var MAX_BANE_EARNABLE:Int = 15;
	
	public function new() {
		
	}
	
	override public function get_uid():String {
		return bane.uid;
	}
	
	
	override public function getCost(rank:Int):Int {
		return getCosting(bane, rank  < 2 ? 1 : rank);
	}
	public inline function getBaseCost(rank:Int):Int {
		return getCosting(bane, rank < 2 ? 1 : rank);
	}
	
	override public function getBoonOrBane():BoonBane {
		return bane;
	}
	
	override public function getUIFields():Array<Dynamic> {
		return null;
	}
	public function toString():String {
		return "[BaneAssign: " + bane.uid + "]";
	}
	
	
	/* INTERFACE troshx.ds.IUpdateWith.IUpdateWith<W> */
	
	public function updateAgainst(ref:BaneAssign):Void 
	{
		
	}
	
	public function spliceAgainst(ref:BaneAssign):Int 
	{
		return 0;
	}
	
}