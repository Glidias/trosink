package troshx.sos.vue;
import haxe.Unserializer;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue;
import js.Browser;
import troshx.sos.core.Armor;
import troshx.sos.core.BodyChar;
import troshx.sos.core.DamageType;
import troshx.sos.core.HitLocation;
import troshx.sos.core.Inventory;
import troshx.sos.core.Shield;
import troshx.sos.core.TargetZone;
import troshx.sos.sheets.CharSheet;
import troshx.sos.vue.InventoryVue.ArmorLayerCalc;
import troshx.sos.vue.input.MixinInput;
import troshx.sos.vue.widgets.GingkoTreeBrowser;
import troshx.util.DiceRoller;
import troshx.util.LibUtil;
import troshx.util.TROSAI;

/**
 * ...
 * @author Glidias
 */
class RangeCalculator extends VComponent<RangeCalculatorData, NoneT>
{

	public function new() 
	{
		super();
		untyped this.mixins = [ MixinInput.getInstance() ];
	}
	
	override public function Data():RangeCalculatorData {
		return new RangeCalculatorData();
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>>  {
		return [
			"inventory" => new InventoryVueArmor(),
			"tree-browser" => new GingkoTreeBrowser()
		];
	}
	@:computed function get_chanceToAtLeastGraze():Float {
		return TROSAI.getAtLeastXSuccessesProb(this.shooterTotalMP, this.shooterTN, this.targetTotalRS);
	}
	@:computed function get_chanceToAtLeastGrazeAtLeastOnce():Float {
		return TROSAI.probabilityAOrB( this.chanceToAtLeastGraze, this.chanceToAtLeastGraze);
	}
	@:computed function get_chanceToAtLeastGrazeTwice():Float {
		return this.chanceToAtLeastGraze * this.chanceToAtLeastGraze;
	}
	
	
	function roundPerc(val:Float):Int {
		return Math.round(val * 100);
	}
	
	@:computed function get_chanceToHitFully():Float {
		return TROSAI.getAtLeastXSuccessesProb(this.shooterTotalMP, this.shooterTN, this.targetTotalRS+1);
	}
	@:computed function get_chanceToHitFullyAtLeastOnce():Float {
		return TROSAI.probabilityAOrB(this.chanceToHitFully, this.chanceToHitFully);
	}
	@:computed function get_chanceToHitFullyTwice():Float {
		return this.chanceToHitFully * this.chanceToHitFully;
	}

	
	@:computed function get_grazePercMargin():Int {
		return roundPerc(this.chanceToAtLeastGraze)- roundPerc(this.chanceToHitFully);
	}
	
	
	@:computed function get_lowShieldCoverage():Array<Dynamic<Bool>> {
		return Shield.getLowCoverage();
	}
	@:computed function get_highShieldCoverage():Array<Dynamic<Bool>> {
		return Shield.getHighCoverage();
	}
	@:computed function get_coverageHitLocations():Array<HitLocation> {
		return BodyChar.getInstance().hitLocations; // getNewHitLocationsFrontSlice();
	}
	
	@:computed function get_hitLocationZeroAVValues():Dynamic<AV3> {
		var ch = coverageHitLocations;
		var dyn:Dynamic<AV3> = {};
		//trace("Hit dummy set up...");
		for (i in 0...ch.length) {
			var h = ch[i];
			LibUtil.setField(dyn, h.id, { avp:0, avc:0, avb:0 }); 
		}
		return dyn;
	}
	
	@:computed function get_hitLocationArmorValues():Dynamic<AV3> {
		var inventory:Inventory = this.targetInventory;
		var armors:Array<ArmorAssign> = inventory.wornArmor;
		var values:Dynamic<AV3>  = this.hitLocationZeroAVValues;
		
		var body:BodyChar =  BodyChar.getInstance();
		var ch = body.hitLocations;
		
	
		var nonFirearmMissile:Bool = !this.shooterFirearm;
		
		for (i in 0...ch.length) {
			var ider = ch[i].id;
			var cur = LibUtil.field(values, ider);
			cur.avc = 0;
			cur.avp = 0;
			cur.avb = 0;
		}
		
		for (i in 0...armors.length) {
			var a:Armor = armors[i].armor;
			var layerMask:Int = 0;

			if (a.special != null && a.special.wornWith != null && a.special.wornWith.name != "" ) {
				layerMask = inventory.layeredWearingMaskWith(a, a.special.wornWith.name, body);	
			}
			a.writeAVVAluesTo(values, body, layerMask, nonFirearmMissile, 0);	
		
			
		}
		
		/*
		for (i in 0...values.length) {
			values[i].avp += 
		}
		*/
		
		
		return values;
	}
	
	inline function getArmorRS(baseRS:Int, shooterDamage:Int, av:Int):Int {
		return baseRS + (shooterDamage > av ? 0 : 1 + av - shooterDamage);
	}
	
	@:computed function get_rangedOutfitChanceToBreach():Float {

		var hitAVs:Dynamic<AV3>  = this.hitLocationArmorValues;
		var hitFields = Reflect.fields(hitAVs);
		var lowestAV:Int = 999999999;
		for (i in 0...hitFields.length) {
			var f = hitFields[i];
			var av:Int = LibUtil.field(hitAVs, f).avp;	
			if (av < lowestAV) lowestAV = av;
		}
		
		var inventory:Inventory = this.targetInventory;
		
		var heldShield:Shield =  inventory.findHeldShield();
		var shieldSize:Int = heldShield != null ? heldShield.size + 1: 0;
		var shieldPosition:Int = heldShield != null ? inventory.shieldPosition : 0;
		var si:Int = shieldSize == 0 ? 0 : shieldSize - 1;
		var coverageTruth:Dynamic<Bool> = shieldPosition != Shield.POSITION_HIGH ? lowShieldCoverage[si] :  highShieldCoverage[si];
		
		
		var totalMP:Int = shooterTotalMP;
		var tn:Int = this.shooterTN;
		var targetRS:Int = this.targetTotalRS;
		var shooterDamage:Int = this.shooterDamage;
		var body:BodyChar = BodyChar.getInstance();
		var targetZones = body.targetZones;
		var totalProb:Float = TROSAI.getAtLeastXSuccessesProb(totalMP, tn, getArmorRS(targetRS, shooterDamage, lowestAV+this.avValueToOvercome)  ) ; // assume 1st slot is critical hit always
		
		for ( i in 1...body.missileHitLocations.length) {
			var tz = targetZones[i];
			for (p in 0...tz.parts.length) {
				var prob = tz.partWeights[p] / tz.weightsTotal;
				var hitLocIndex:Int  = tz.parts[p];
				var hitLoc =  body.hitLocations[hitLocIndex];
				var gotShield:Bool = heldShield != null && LibUtil.field(coverageTruth, hitLoc.id) != null;
				var shieldAV:Int =  gotShield ? heldShield.AV : 0;
			
				//prob *= LibUtil.field(coverageTruth, hitLoc.id) != null ?  LibUtil.field(coverageTruth, hitLoc.id) ? 0 :  0.5 : 1;  // 50/50 chance for shield arm/shield side coverage cases
				var av3:AV3 = LibUtil.field(hitAVs, hitLoc.id);
				var av:Int = av3 != null ? av3.avp : 0;
				
				var layerAV:Int = av != 0 ? getLayerValue(av, hitLocIndex, hitLoc.id) : 0;
				
				if (gotShield && !LibUtil.field(coverageTruth, hitLoc.id)) {  // half half distribution
					prob *= .5; 
					var halfProb:Float = prob;
					prob = halfProb * TROSAI.getAtLeastXSuccessesProb(totalMP, tn, getArmorRS(targetRS, shooterDamage, layerAV+ av + 4+this.avValueToOvercome+shieldAV ) );
					prob += halfProb * TROSAI.getAtLeastXSuccessesProb(totalMP, tn, getArmorRS(targetRS, shooterDamage, layerAV+ av + 4+this.avValueToOvercome ) );
				}
				else prob *= TROSAI.getAtLeastXSuccessesProb(totalMP, tn, getArmorRS(targetRS, shooterDamage, layerAV+ av+ 4+this.avValueToOvercome+shieldAV )  );
				
				totalProb += prob;
			}
		}
		
		
		return  (totalProb / body.missileHitLocations.length);
	}
	
	
	@:computed function get_chanceToBypassShield():Float {
		var shieldSize:Int = this.targetShield;
		var shieldPosition:Int = this.targetShieldPosition;
		var si:Int = shieldSize == 0 ? 0 : shieldSize - 1;
		var coverageTruth:Dynamic<Bool> = shieldPosition != Shield.POSITION_HIGH ? lowShieldCoverage[si] :  highShieldCoverage[si];
		
		
		var body:BodyChar = BodyChar.getInstance();
		var targetZones = body.targetZones;
		var totalProb:Float = 1; // assume 1st slot is critical hit always
		
		for ( i in 1...body.missileHitLocations.length) {
			var tz = targetZones[i];
			for (p in 0...tz.parts.length) {
				var prob = tz.partWeights[p] / tz.weightsTotal;
				var hitLoc =  body.hitLocations[tz.parts[p]];
				prob *= LibUtil.field(coverageTruth, hitLoc.id) != null ?  LibUtil.field(coverageTruth, hitLoc.id) ? 0 :  0.5 : 1;  // 50/50 chance for shield arm/shield side coverage cases
				totalProb += prob;
			}
		}
		return shieldSize > 0 ? (totalProb / body.missileHitLocations.length) : 1;
	}
	
	@:computed function get_shooterTotalMP():Int {
		return  this.shooterProf  + this.aimBonus + this.shooterMiscMPMod;
	}
	
	@:computed function get_breachArmorRSChance():Float {
		var inven:Inventory = this.targetInventory;
		var detailResult:Float = 0;
		if ( inven != null) {
			detailResult = this.rangedOutfitChanceToBreach;
		}
		
		var plainResult:Float = TROSAI.getAtLeastXSuccessesProb(this.shooterTotalMP, this.shooterTN, this.breachArmorRS);
		return inven!= null ? detailResult : plainResult;
	}
	@:computed function get_breachArmorRSChanceAtLeastOnce():Float {
		return TROSAI.probabilityAOrB(this.breachArmorRSChance, this.breachArmorRSChance);
	}
	@:computed function get_breachArmorRSChanceTwice():Float {
		return this.breachArmorRSChance * this.breachArmorRSChance;
	}
	
	@:computed function get_breachArmorRS():Int {
		return targetTotalRS + additionalRSForAV;
	}
	
	@:computed function get_aimBonus():Int {
		return  Math.floor(this.shooterAim * 2 * this.aimMultiplier);
	}
	@:computed function get_targetTotalRS():Int {
		return  this.targetMiscRSMod + this.targetBehaviourRS + this.targetCoverRS +  this.targetDistanceRS +  RangeCalculatorData.BASE_RS; // Math.floor(this.shooterAim * 2 * this.aimMultiplier) + this.shooterMiscMPMod;
	}
	
	@:computed function get_targetDistanceRS():Int {
		var q = this.targetDistance / this.shooterRange;
		return  this.distRounding == RangeCalculatorData.ROUND_OFF ? Math.round(q) : this.distRounding == RangeCalculatorData.ROUND_UP ? Math.ceil(q) : Math.floor(q);
	}
	
	@:computed function get_aimMultiplier():Float {
		return this.shooterRapidShot ?  0.5 :  1;
	}
	
	@:computed function get_additionalRSForAV():Int {
		var d = this.shooterDamage;
		return d > this.avValueToOvercome + 4  ? 0 : 1 + this.avValueToOvercome + 4 - d;
	}
	
	@:computed function get_domainId():String {
		return Globals.DOMAIN_RANGECALC;
	}
	
	
	function loadCharacterClipboardWindow():Void {
		if (this.emptyClipboard) {
			this.avValueToOvercome = 0;
			this.targetInventory = new Inventory();
			this.targetChar = null;
			_vRefs.clipboardWindow.close();
			return;
		}
		if (loadCharContents(this.clipboardLoadContents)) {
			_vRefs.clipboardWindow.close();
		}
	}
	function loadCharContents(contents:String):Bool 
	{
		var newItem:Dynamic;
		
		
		try {
			newItem = new Unserializer(contents).unserialize();
		}
		catch (e:Dynamic) {
			trace(e);
			Browser.alert("Sorry, failed to unserialize save-content string!");
			return false;
		}
		if (!Std.is(newItem, CharSheet) && !Std.is(newItem, Inventory) ) {
		
			trace(newItem);
			Browser.alert("Sorry, unserialized type isn't CharSheet/Inventory!");
			return false;
		}
		var me:CharSheet =  LibUtil.as(newItem, CharSheet);
		if (me != null) {
			me.postSerialization();
			this.avValueToOvercome = 0;
			this.targetInventory = me.inventory;
			this.targetChar = me;
			return true;
		}
		
		var inv:Inventory = LibUtil.as(newItem, Inventory);
		if (inv != null) {
			inv.postSerialization();
			this.avValueToOvercome = 0;
			this.targetChar = null;
			this.targetInventory = inv;
			return true;
		}
		
		
		return false;
	}
	
	
	static var SAMPLE_AV:AV3 = {avc:0, avp:0, avb:0};
	//static var SAMPLE_RESULTS:ArmorCalcResults =   new ArmorCalcResults();
	
	
	function sortArmorLayers(a:ArmorLayerCalc, b:ArmorLayerCalc):Int {
	  if (a.layer < b.layer) return -1;
	  else if (a.layer > b.layer) return 1;
	  return 0;
	} 
	
	function getLayerValue(dominantAV:Int, hitLocationIndex:Int, hitLocationId:String):Int {
		//this.calcAVColumn = columnNum;
		//this.calcAVRowIndex = rowIndex;
		
		
		// perfrorm calculation
		
		var hitLocArmorValues = this.hitLocationArmorValues;
		var coverageLocs = coverageHitLocations;
	
		var hitLocationMask:Int = (1 << hitLocationIndex);
		var curRow:AV3 = LibUtil.field( hitLocArmorValues, hitLocationId);
		
		//var results:ArmorCalcResults = SAMPLE_RESULTS; // this.calcArmorResults;
		//results.damageType = DamageType.PIERCING;
		//results.hitLocationIndex = hitLcati;
		//results.layer = 0;
		//results.av = columnNum == 1 ? curRow.avc : columnNum == 2  ? curRow.avp : curRow.avb;
		//results.av = 0;
		
		//results.armorsLayer = [];
		var armorsProtectable = [];
		//results.armorsCrushable = [];
		
		// else look for armors whose computed AVs at hit location is tabulated to match results.av
		var sampleAV:AV3 = SAMPLE_AV;
		var inventory = targetInventory;
		var armorList = inventory.wornArmor;
		var body:BodyChar = BodyChar.getInstance();
		var targetingZoneMask:Int = 0;// this.targetingZoneMask;
		var isNonFirearmMissile = !this.shooterFirearm;

		//if (dominantAV != 0) {  // av found at location, find dominant armors and layers
			var comparisonLayerMasks:Array<Int>  = [];  // temp for case to layers
		
			for (i in 0...armorList.length) {
				var a:Armor = armorList[i].armor;
				if (LibUtil.field(a.coverage, hitLocationId) == null) {
					comparisonLayerMasks.push(0);
					continue;
				}
				
				var layerMask:Int = 0;
				
				if (a.special != null && a.special.wornWith != null && a.special.wornWith.name != "" ) {
					layerMask = inventory.layeredWearingMaskWith(a, a.special.wornWith.name, body);	
				}
				comparisonLayerMasks.push(layerMask);
				
				
				if ( a.writeAVsAtLocation(body, hitLocationId, hitLocationMask, sampleAV, layerMask, isNonFirearmMissile, targetingZoneMask, true) ) {
					var compareAV:Int = sampleAV.avp;
					
					if (compareAV == dominantAV) {
						armorsProtectable.push(a);
					}
					
				}
			}
			
			if (armorsProtectable.length != 0)  {
				
				// now, find highest possible layers
				var highest:Int = 0;
				
				
				var comparisonLayeredArmor:Array<ArmorLayerCalc> = [];
				
				for (i in 0...armorList.length) {
					var a:Armor = armorList[i].armor;
					if (LibUtil.field(a.coverage, hitLocationId) == null) continue;
					
					var c = a.getLayerValueAt(hitLocationMask, comparisonLayerMasks[i]);
					// get layer value of armor.. get highest layer value among all to be sorted later on
					if (c > 0) {
						comparisonLayeredArmor.push({armor:a, layer:c});
					}	
				}
				
				if (comparisonLayeredArmor.length > 0) {
				

					haxe.ds.ArraySort.sort(comparisonLayeredArmor, sortArmorLayers);

					if (armorsProtectable.length == 1 && armorsProtectable[0]== comparisonLayeredArmor[comparisonLayeredArmor.length-1].armor) {
						comparisonLayeredArmor.pop();
					}
					if (comparisonLayeredArmor.length > 0) {
						return comparisonLayeredArmor[comparisonLayeredArmor.length - 1].layer;

						/*
						var i = comparisonLayeredArmor.length;
						while(--i > -1) {
							if (comparisonLayeredArmor[i].layer == results.layer) {
								results.armorsLayer.push(comparisonLayeredArmor[i].armor);
							}
						}
						var ind:Int;
						if (results.armorsProtectable.length == 1 && (ind = results.armorsLayer.indexOf(results.armorsProtectable[0])  )>=0 ) {
							comparisonLayeredArmor.splice(ind, 1);
						}
						*/
					
						
						/*
						if (results.armorsProtectable.length >=2 && results.armorsLayer.length == 1 && (ind = results.armorsProtectable.indexOf(results.armorsLayer[0] ) )>=0 ) {
							results.armorsProtectable.splice(ind, 1);
						}
						*/
					}
					
					
					
				
				}
			
			}
			
		//}
		return 0;
	}
	
	function openTreeBrowser():Void {
		if (!treeBrowserInited) {
			treeBrowserInited = true;
		}
		Vue.nextTick( function() {
			_vRefs.treeBrowser.open();
		});
	}
	
	function openClipboardWindow():Void {
		clipboardLoadContents = "";
		_vRefs.clipboardWindow.open();
	}
	
	@:computed function get_emptyClipboard():Bool {
		return StringTools.trim(clipboardLoadContents) == "";
	}
	
	
	@:computed function get_availableTypes():Dynamic<Bool> {
		return {
			"troshx.sos.sheets.CharSheet": true,
			"troshx.sos.core.Inventory": true
		};
	}
	@:computed function get_breachLabel():String {
		return targetInventory == null ? "AV" : "Armor Outfit" ;
	}
	
	function openFromTreeBrowser(contents:String, filename:String, disableCallback:Void->Void):Void {
		if ( loadCharContents(contents) ) {
			_vRefs.treeBrowser.close();
		}
		this.autoLoadChar = null;
	}
	
	
	function closeArmorOutfit():Void {
		this.targetInventory = null;
		this.targetChar = null;
	}
	
	override public function Template():String {
		return '<div>
			<sweet-modal ref="clipboardWindow" :class="{reset:true}" >		
				<div>
					You can manually paste saved data text stream into text-area and click on Load Character/Inventory to open a new target character/inventory for ranged testing!
					<div>
						<textarea ref="savedCharTextArea" character-set="UTF-8" v-model="clipboardLoadContents" style="min-height:60px;"></textarea>	
					</div>
					<div><button v-on:click="loadCharacterClipboardWindow()">{{!emptyClipboard ? "Load Character/Inventory" : "New Inventory Outfit" }}</button></div>
				</div>
			</sweet-modal>
			<sweet-modal ref="treeBrowser" :class="{reset:true}" v-if="treeBrowserInited" >		
				<tree-browser :availableTypes="availableTypes" v-on:open="openFromTreeBrowser" :initialDomain="domainId" :autoLoad="autoLoadChar" />
			</sweet-modal>
	
			<h1>Firing Range Viability Calculator &nbsp;&nbsp;<button v-on:click="openTreeBrowser">&#127759;</button> <button v-on:click="$$refs.clipboardWindow.open()">&#128203;</button> <button v-if="targetInventory!=null" v-on:click="closeArmorOutfit">&#10060; Close Armor Outfit</button></h1>
			<h4>Shooter</h4>
			<div><label>Profeciency Level: <InputInt :obj="$$data" prop="shooterProf" :min="0" /></label></div>
			<div><label>Aim Phases (Max 3 phases x2 MP): <InputInt :obj="$$data" prop="shooterAim" :min="0" :max="3" /></label> <b><i>{{ aimBonus }}</i></b></div>
			<div><label>Misc MP Mod: <InputInt :obj="$$data" prop="shooterMiscMPMod"  /></label> <i>(eg. to deal with specific Rapid shot penalties and such..)</i></div>
			<div>Total MP: <b>{{ shooterTotalMP }}</b></div>
			<div><label><input type="checkbox" v-model="shooterRapidShot"></input> Rapid Shot?</label> <i>(Also includes house-rule that Halves Aim Bonus)</i></div>
			<div><label>Weapon/Firer Range Band (yards): <InputInt :obj="$$data" prop="shooterRange" :min="1" /></label></div>
			<div><label>Effective Weapon Damage: <InputInt :obj="$$data" prop="shooterDamage"  /></label></div>
			<div><label>Weapon TN: <InputInt :obj="$$data" prop="shooterTN" :min="1" /></label></div>
			<div><label>Firearm? <input type="checkbox" v-model="shooterFirearm"></input></label></div>
			
			<h4>Target</h4>
			<div><label>Misc RS Modifier: <InputInt :obj="$$data" prop="targetMiscRSMod"  /></label></div>
			<div><label>Behaviour RS: <InputInt :obj="$$data" prop="targetBehaviourRS"  /></label> <i>(eg. Moved:+1 RS, Sprint/Charged/In-Melee:+2 RS)</i></div>
			<div><label>Environmental Cover RS:</label> <select number v-model.number="targetCoverRS"><option :value="li.value" :key="i" v-for="(li, i) in coverOptions">{{ li.label }} ({{li.value}})</option></select></div>
			<div>Distance (yards): <InputInt :obj="$$data" prop="targetDistance" :min="0" /><select number v-model.number="distRounding"><option v-for="(li, i) in roundingOptions" :key="i" :value="li.value">{{ li.label }}</option></select> <b>+{{targetDistanceRS}} RS</b></div>
			
			<br/>
			<div>Target RS: <b>{{ targetTotalRS }}</b></div>
			<div><b>{{ roundPerc(chanceToAtLeastGraze) }}</b>% Chance to at least Graze or Hit Fully (RS) <span v-if="shooterRapidShot">({{roundPerc(chanceToAtLeastGrazeAtLeastOnce)}}% &gt;=once, {{roundPerc(chanceToAtLeastGrazeTwice)}}% twice)</span></div>
			<div>{{ grazePercMargin }}% Graze Percentage Margin</div>
			<div><b>{{ roundPerc(chanceToHitFully) }}</b>% Chance to Hit Fully <span v-if="shooterRapidShot">({{roundPerc(chanceToHitFullyAtLeastOnce)}}% &gt;=once, {{roundPerc(chanceToHitFullyTwice)}}% twice)</span></div>
			<div v-if="targetInventory != null"><i>Armor Outfit Loaded...</i>:</div>
			<div>{{ targetInventory != null ? "Global AV Modifier:" : "AV Value to overcome?:"}} <InputInt :obj="$$data" prop="avValueToOvercome" :min="0" /></div>
			<div v-show="additionalRSForAV>0 && targetInventory == null">Target Armor RS: <b>{{breachArmorRS}}</b></div>
			<div v-show="additionalRSForAV>0 || targetInventory != null"><b>{{roundPerc(breachArmorRSChance)}}</b>% Chance to Hit &amp; Breach Given {{breachLabel}} + TOU4<span v-if="shooterRapidShot">({{roundPerc(breachArmorRSChanceAtLeastOnce)}}% &gt;=once, {{roundPerc(breachArmorRSChanceTwice)}}% twice)</span></div>
			<div v-if="targetInventory == null">
				<div><span class="shield-icon-inv">☗</span> With Shield? <select v-model.number="targetShield" number><option :value="0">None</option><option :value="1">Small</option><option :value="2">Medium</option><option :value="3">Large</option></select></div>
				<div v-show="targetShield!=0">Shield Position: <select v-model.number="targetShieldPosition" number><option :value="0">Low</option><option :value="1">High</option></select> <span class="shield-icon-inv">☗</span></div>
				<div v-if="targetShield > 0"><b>{{roundPerc(chanceToBypassShield)}}</b>% chance to bypass Shield alone</div>
				<div v-if="targetShield > 0"><b>{{roundPerc(chanceToBypassShield*chanceToAtLeastGraze)}}</b>% chance bypass &amp; at least Graze</div>
				<div v-if="targetShield > 0"><b>{{roundPerc(chanceToBypassShield*chanceToHitFully)}}</b>% chance bypass &amp; to Hit Fully</div>
				<div v-if="targetShield > 0 && additionalRSForAV>0"><b>{{roundPerc(chanceToBypassShield*breachArmorRSChance)}}</b>% chance to bypass &amp; Penetrate given AV + TOU4</div>
			</div>
			<div v-else>
				<inventory :inventory="targetInventory"></inventory>
			</div>
		</div>';
	}
	
}

class RangeCalculatorData  {
	var shooterProf:Int = 1;
	var shooterAim:Int = 0 ;
	var shooterTN:Int = 7;
	var shooterMiscMPMod:Int = 0;
	var shooterRapidShot:Bool = false;
	var shooterRange:Int = 1;
	var shooterFirearm:Bool = false;
	var shooterDamage:Int = 0;
	
	public static inline var ROUND_DOWN:Int = 0;
	public static inline var ROUND_OFF:Int = 1;
	public static inline var ROUND_UP:Int = 2;
	
	public static inline var COVER_NONE:Int = 0;
	public static inline var COVER_HALF:Int = 2;
	public static inline var COVER_34:Int = 3;
	public static inline var COVER_MURDERHOLE:Int = 4;
	

	
	var targetMiscRSMod:Int = 0;
	var targetBehaviourRS:Int = 0;
	var targetCoverRS:Int = COVER_NONE;
	var targetDistance:Int = 0;
	var targetShield:Int = 0;
	var targetShieldPosition:Int = 0;
	
	var distRounding:Int = ROUND_DOWN;
	
	var targetInventory:Inventory = null;
	var targetChar:CharSheet = null;
	
	var avValueToOvercome:Int = 0;
	
	var autoLoadChar:String =  Globals.AUTO_LOAD;
	var clipboardLoadContents:String = "";
	var treeBrowserInited:Bool = false;
	
	var coverOptions:Array<Dynamic> = [
		{label:"None", value:COVER_NONE },
		{label:"Half", value:COVER_HALF },
		{label:"3/4", value:COVER_34 },
		{label:"Murderhole", value:COVER_MURDERHOLE }
	];
	var roundingOptions:Array<Dynamic> = [
		{label:"Round Down", value:ROUND_DOWN },
		{label:"Round Off", value:ROUND_OFF },
		{label:"Round Up", value:ROUND_UP }
	];
	
	public static inline var BASE_RS:Int = 4;
		
	
	
	public function new() {
		
	}
}

