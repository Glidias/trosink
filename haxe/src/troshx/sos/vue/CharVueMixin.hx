package troshx.sos.vue;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.chargen.CharGenData;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.BoonBane.BoonAssign;
import troshx.sos.core.BoonBane.BoonBaneAssign;
import troshx.sos.core.Inventory;
import troshx.sos.core.Modifier;
import troshx.sos.core.Profeciency;
import troshx.sos.core.School;
import troshx.sos.core.Weapon;
import troshx.sos.sheets.CharSheet;
import troshx.sos.sheets.EncumbranceTable.EncumbranceRow;
import troshx.sos.vue.widgets.BoonBaneApplyDetails;

/**
 * Common charsheet related derived attributes cached by vue proxy, boilerplate.
 * @author Glidias
 */
class CharVueMixin extends VComponent<CharVueMixinData,NoneT>
{

	public function new() 
	{
		super();
	}
	override function Data():CharVueMixinData {
		return untyped {};
	}
	
	static var INSTANCE:CharVueMixin;
	public static function getSampleInstance():CharVueMixin {
		return (INSTANCE != null  ? INSTANCE : INSTANCE = new CharVueMixin());
	}
	
	
	// inventory
	
	@:computed  function get_encumbered():Bool   { return this.totalWeight >= this.CAR;  }
	
	@:computed  function get_totalWeight():Float   { return this.char.totalWeight;  }
	@:computed  function get_encumbranceLvl():Int   { return this.char.encumbranceLvl;  }
	
	@:computed function get_offhandWeapon():Weapon {
		return char.inventory.getOffhandWeapon();
	}
	@:computed function get_masterWeapon():Weapon {
		return char.inventory.getMasterWeapon();
	}
	
	@:computed function get_reachBase():Int {
		return Inventory.getReachBetween(offhandWeapon, masterWeapon);
	}
	@:computed function get_reach():Int {
		return Std.int( char.getModifiedValue(Modifier.REACH, reachBase) );
	}
	
	// derived 
	@:computed function get_adr():Int { return this.char.adr;  }
	@:computed  function get_mob():Int   { return this.char.mob;  }
	@:computed  function get_car():Int  { return this.char.car;  }
	@:computed  function get_cha():Int  { return this.char.cha;  }
	@:computed  function get_tou():Int   { return this.char.tou;  }
	

	// derived with mods
	@:computed  function get_ADR():Int {
		return this.char.ADR;
	}
	
	@:computed  function get_MOB():Int 
	{
		return this.char.MOB;
	}
	
	@:computed  function get_CAR():Int 
	{
		return this.char.CAR;
	}
	
	@:computed  function get_CHA():Int 
	{
		return this.char.CHA;
	}
	
	@:computed  function get_startingGrit():Int 
	{
		return this.char.startingGrit;
	}
	
	@:computed  function get_TOU():Int 
	{
		return this.char.TOU;
	}
	
	@:computed  function get_GRIT():Int 
	{
		return this.char.GRIT;
	}

	@:computed  function get_baseGrit():Int 
	{
		return this.char.baseGrit;
	}
	
	// base with modifiers
	@:computed function get_STR():Int { return this.char.STR;  } 
	@:computed function get_AGI():Int { return this.char.AGI;  } 
	@:computed function get_END():Int { return this.char.END;  } 
	@:computed function get_HLT():Int {return this.char.HLT;  } 
	@:computed function get_WIP():Int { return this.char.WIP;  } 
	@:computed function get_WIT():Int { return this.char.WIT;  } 
	@:computed function get_INT():Int { return this.char.INT;  } 
	@:computed function get_PER():Int { return this.char.PER;  } 
	
	@:computed function get_negativeOrZeroStat():Bool {
		return this.STR <= 0 || this.AGI <= 0 || this.END <= 0 	 || this.AGI <= 0 || this.HLT <= 0 
		|| this.WIP  <= 0 || this.WIT <= 0 || this.INT <= 0 || this.PER <= 0;
		//|| this.ADR <= 0 || this.MOB <= 0 || this.CAR <= 0 || this.CHA <= 0 || this.TOU  <= 0;
	}
	
	// raw without modifiers
	@:computed function get_strength():Int { return this.char.strength;  } 
	@:computed function get_agility():Int { return this.char.agility;  } 
	@:computed function get_endurance():Int { return this.char.endurance;  } 
	@:computed function get_health():Int {return this.char.health;  } 
	@:computed function get_willpower():Int { return this.char.willpower;  } 
	@:computed function get_wit():Int { return this.char.wit;  } 
	@:computed function get_intelligence():Int { return this.char.intelligence;  } 
	@:computed function get_perception():Int { return this.char.perception;  } 
	
	
	// everything else bleh.. (violates DRY but ah well..)
	
	@:computed inline function get_SDB():Int 
	{
		return this.char.SDB;
	}
	
	@:computed inline function get_labelRace():String 
	{
		return this.char.labelRace;
	}

	
	@:computed inline function get_labelSchool():String 
	{
		return this.char.labelSchool;
	}
	
	
	@:computed inline function get_baseCP():Int {
		return this.char.baseCP;
	}
	
	@:computed inline function get_CP():Int {
		return this.char.CP;
	}
	
	@:computed inline function get_meleeCP():Int 
	{
		return this.char.meleeCP;
	}
		
	@:computed inline function get_totalPain():Int 
	{
		return this.char.totalPain;
	}
	@:computed inline function get_totalBloodlost():Int 
	{
		return this.char.totalBloodLost;
	}
	
	@:computed inline function get_schoolCP():Int 
	{
		return this.char.schoolCP;
	}
	
	@:computed function get_arcPointsAvailable():Int 
	{
		return this.char.arcPointsAvailable;
	}
	
	@:computed function get_encumbranceLvlRow():EncumbranceRow
	{
		return this.char.encumbranceLvlRow;
	}
	
	@:computed function get_encumberedBeyond():Bool {
		return this.char.encumberedBeyond;
	}

	@:computed function get_skillPenalty():Int 
	{
		return this.char.skillPenalty;
	}
	
	@:computed function get_recoveryRate():Float 
	{
		return this.char.recoveryRate;
	}
	var recoveryRateAmountBase(get, never):Float;
	function get_recoveryRateAmountBase():Float 
	{
		return recoveryRate * END; 
	}
	
	var recoveryRateAmount(get, never):Float;
	function get_recoveryRateAmount():Float 
	{
		return  char.clampIntZero(recoveryRate * char.getModifiedValue(Modifier.FATIQUE_END, END) ); 
	}
	
	@:computed function get_exhaustionRate():Float 
	{
		return this.char.exhaustionRate;
	}
	
	
	
	// ALl duplicates from charGenData (factored out), so long as  relavant to regular charsheet.
	
	@:computed function get_addressedAs():String {
		
		return char.uid;
	}
	var profCoreMeleeListNames(get, never):Array<String>;
	function get_profCoreMeleeListNames():Array<String> {
		return Profeciency.getLabelsOfArrayProfs(Profeciency.getCoreMelee(), Profeciency.MASK_ALL);
	}
	
	var profCoreRangedListNames(get, never):Array<String>;
	function get_profCoreRangedListNames():Array<String> {
		return Profeciency.getLabelsOfArrayProfs(Profeciency.getCoreRanged(), Profeciency.MASK_ALL);
	}
	
	
	var hasSchool(get, never):Bool;
	inline function get_hasSchool():Bool {
		return char.school != null;	
	}
	
	var schoolProfLevel(get, never):Int;
	inline function get_schoolProfLevel():Int {
		return hasSchool ? char.schoolLevel : 0;	
	}
	
	var schoolTags(get, never):Array<String>;
	inline function get_schoolTags():Array<String> {
		return hasSchool  && char.schoolBonuses != null ? char.schoolBonuses.getTags() : [];	
	}
	
	var maxMasterySlots(get, never):Int;
	function get_maxMasterySlots():Int {
		var r = char.schoolLevel >= School.MASTERY_LEVEL ? 1 : 0;
	
		return hasSchool ? r : 0;
	}
	
	var boonsArray(get, never):Array<BoonAssign>;
	inline function get_boonsArray():Array<BoonAssign> {
		return char.boonsArray;
	}
	var banesArray(get, never):Array<BaneAssign>;
	inline function get_banesArray():Array<BaneAssign> {
		return char.banesArray;
	}
	
	var shouldShowBnBs(get, never):Bool;
	function get_shouldShowBnBs():Bool 
	{
		return showBnBs;
	}
	
	@:computed function get_maxBoonsSpendableLeft():Int {
		return 999;
	}
	
	
	
	function getBnBSlug(name:String):String {
		return BoonBaneApplyDetails.getSlug(name);
	}

	function getEmptyWealthAssign():WealthAssetAssign {
		return this.char.getEmptyWealthAssetAssign(1);
	}

	
	var isHuman(get, never):Bool;
	inline function get_isHuman():Bool {
		return char.race.name == "Human";
	}
		
	public function restoreAnyBnBWithMask(msk:Int, superMask:Int):Void {
		var arr = baneAssignList;
		var arr2 = boonAssignList;
		var restored:Bool = false;
		var restoredBane:troshx.sos.core.BoonBane.BaneAssign = null;
		var restoredBoon:troshx.sos.core.BoonBane.BoonAssign = null;
		/*
		if (superMask != 0) {
			for (i in 0...arr.length) {  
				var a = arr[i];
				if ( a._canceled && (a.bane.channels & superMask) != 0 ) {
					superMask &= ~a.bane.channels;
					a._canceled = false;
				}
			}
			for (i in 0...arr2.length) { 
				var a = arr2[i];
				if ( a._canceled && (a.boon.channels & superMask) != 0 ) {
					superMask &= ~a.boon.channels;
					a._canceled = false;
				}
			}
		}
		*/
		
		msk |= superMask;
		
		for (i in 0...arr.length) {  // banes first
			var a = arr[i];
			if ( a._canceled && (a.bane.channels & msk)!=0 ) {
				a._canceled = false;
				//msk &= ~a.bane.channels;
				///*
				if (a.rank > 0 && restoredBane == null)  {
					restoredBane = a;
					//break;
				}
				//*/
			}
		}
		
		if (restoredBane != null) {
			msk &= ~(restoredBane.bane.channels | restoredBane.bane.superChannels);
		}
	
		
		//if (restoredBane == null) {
			for (i in 0...arr2.length) {
				var a = arr2[i];
				if ( a._canceled &&  (a.boon.channels & msk)!=0 ) {
					a._canceled = false;
					//msk &= ~a.boon.channels;
					
					///*
					if (a.rank > 0 && restoredBoon == null)  {
						restoredBoon = a;
						//break;
					}
					//*/
				}
			}
		//}
		
		if (restoredBoon != null) {
			checkBoonAgainstOthers(restoredBoon);
		}
		else if (restoredBane != null) {
			checkBaneAgainstOthers(restoredBane);
		}
		
	}
	

	public function resetBB(bba:troshx.sos.core.BoonBane.BoonBaneAssign, isBane:Bool):Void {
		//trace("REMOVING:" + bba + " , " + isBane);
		if (isBane) {
			//char.mayRemoveBane(cast bba);  // this is done elsewhere
			
			var bane:Bane = cast bba.getBoonOrBane();
			var ba;
			var i = baneAssignList.indexOf(cast bba);
			ba = bane.getAssign(0, char);
			ba._costCached = bane.costs[0];
			ba._forcePermanent = bba._forcePermanent;
			
			ba.discount = bba.discount;
			ba._minRequired = bba._minRequired;
			ba._canceled = bba._canceled;
			CharGenData.dynSetArray(this.baneAssignList, i, ba );
			
		}
		else {
			var boonAssign:BoonAssign = cast bba;
			var boon:Boon = boonAssign.boon;
			var ba;
			var i = boonAssignList.indexOf(cast bba);
			ba = boon.getAssign(0, char);
			ba.discount = boonAssign.discount;
			ba.rank = bba._minRequired;
			ba._remainingCached = maxBoonsSpendableLeft;
			
			ba._costCached = boon.costs[0];
			ba._forcePermanent = bba._forcePermanent;
			ba._minRequired = bba._minRequired;
			ba._canceled = bba._canceled;
			CharGenData.dynSetArray(this.boonAssignList, i, ba );
			if (ba.rank > 0) {
				i = char.boonsArray.indexOf(boonAssign);
				var oldBA = char.boonsArray[i];
				CharGenData.dynSetArray(char.boonsArray, i, ba );
				char.boonAssignReplaced(ba, oldBA);
			}
		}
	}
		
	public function checkBaneAgainstOthers(baneAssign:troshx.sos.core.BoonBane.BaneAssign):Void {
		var arr = baneAssignList;
		var arr2 = boonAssignList;
		baneAssign._canceled = false;

		
		var msk:Int = baneAssign.bane.channels | baneAssign.bane.superChannels;
		if (msk == 0) return;
		
		for (i in 0...arr.length) {
			var a = arr[i];
			if ( a != baneAssign && (a.bane.channels & msk)!=0 ) {
				a._canceled = true;
			}
		}
		for (i in 0...arr2.length) {
			var a = arr2[i];
			if (  (a.boon.channels & msk)!=0 ) {
				a._canceled = true;
			}
		}
	}
	

	
	// dupliacte semi
	public function checkBoonAgainstOthers(boonAssign:BoonAssign):Void {
		var arr = baneAssignList;
		var arr2 = boonAssignList;
		boonAssign._canceled = false;
	
		
		var msk:Int = boonAssign.boon.channels | boonAssign.boon.superChannels;
		if (msk  == 0) return;
	
		for (i in 0...arr.length) {
			var a = arr[i];
			if (   (a.bane.channels & msk)!=0 ) {
				a._canceled = true;
			}
		}
		for (i in 0...arr2.length) {
			var a = arr2[i];
			if ( a != boonAssign && (a.boon.channels & msk)!=0 ) {
				a._canceled = true;
			}
		}
		
	}
	
	public function uncancel(bba:BoonBaneAssign, isBane:Bool):Void {
		bba._canceled = false;
		if (isBane) {
		
			checkBaneAgainstOthers(cast bba);
		}
		else {
			
			checkBoonAgainstOthers(cast bba);
		}
	}
		
	public function addBB(bba:BoonBaneAssign, isBane:Bool):Void {
		//trace("ADDING:" + bba + " , " + isBane);
		if (isBane) {
			char.addBane(cast bba);
			checkBaneAgainstOthers(cast bba);
		}
		else {
			char.addBoon(cast bba);
			checkBoonAgainstOthers(cast bba);
		}
		
	}
	public function removeBB(bba:BoonBaneAssign, isBane:Bool):Void {
		//trace("REMOVING:" + bba + " , " + isBane);
		if (isBane) {
			var b:BaneAssign = cast bba;
			char.removeBane(b);
			if ( (b.bane.channels|b.bane.superChannels) != 0 ) {
				restoreAnyBnBWithMask(b.bane.channels, b.bane.superChannels);
			}
			
		}
		else {
			var b:BoonAssign = cast bba;
			char.removeBoon(b);
			if ( (b.boon.channels|b.boon.superChannels) != 0){
				restoreAnyBnBWithMask(b.boon.channels,b.boon.superChannels);
			}
		}
	}
	
	public function updateRankBB(bba:BoonBaneAssign, isBane:Bool, newValue:Int, oldValue:Int):Void {
		//trace("AA");
		if (isBane) {
			char.baneRankUpdated(cast bba, newValue, oldValue);
		}
		else {
			char.boonRankUpdated(cast bba, newValue, oldValue);
		}
	}
	
	public function updateCanceledBB(bba:BoonBaneAssign, isBane:Bool, newValue:Bool, oldValue:Bool):Void {
		//trace("AA");
		if (isBane) {
			char.baneRankCanceledChange(cast bba, newValue, oldValue);
		}
		else {
			char.boonRankCanceledChange(cast bba, newValue, oldValue);
		}
	}
	
	
}

typedef CharVueMixinData = {
	var char:CharSheet;
	var showBnBs:Bool;
	var boonAssignList:Array<BoonAssign>;
	var baneAssignList:Array<BaneAssign>;
}