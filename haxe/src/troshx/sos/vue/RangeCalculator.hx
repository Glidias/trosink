package troshx.sos.vue;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.core.BodyChar;
import troshx.sos.core.Shield;
import troshx.sos.vue.input.MixinInput;
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
		return  TROSAI.getAtLeastXSuccessesProb(this.shooterTotalMP, this.shooterTN, this.breachArmorRS);
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
		return d > this.avValueToOvercome  ? 0 : 1 + this.avValueToOvercome - d;
	}
	
	
	override public function Template():String {
		return '<div>
			<h1>Firing Range Viability Calculator</h1>
			<h4>Shooter</h4>
			<div><label>Profeciency Level: <InputInt :obj="$$data" prop="shooterProf" :min="0" /></label></div>
			<div><label>Aim Phases (Max 3 phases x2 MP): <InputInt :obj="$$data" prop="shooterAim" :min="0" :max="3" /></label> <b><i>{{ aimBonus }}</i></b></div>
			<div><label>Misc MP Mod: <InputInt :obj="$$data" prop="shooterMiscMPMod"  /></label> <i>(eg. to deal with specific Rapid shot penalties and such..)</i></div>
			<div>Total MP: <b>{{ shooterTotalMP }}</b></div>
			<div><label><input type="checkbox" v-model="shooterRapidShot"></input> Rapid Shot?</label> <i>(Also includes house-rule that Halves Aim Bonus)</i></div>
			<div><label>Weapon/Firer Range Band (yards): <InputInt :obj="$$data" prop="shooterRange" :min="1" /></label></div>
			<div><label>Effective Weapon Damage: <InputInt :obj="$$data" prop="shooterDamage"  /></label></div>
			<div><label>Weapon TN: <InputInt :obj="$$data" prop="shooterTN" :min="1" /></label></div>
			
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
			
			<div>Additional RS needed to overcome AV?: <span v-show="additionalRSForAV>0">+</span><b>{{additionalRSForAV}}</b></div>
			<div>AV Value to overcome?: <InputInt :obj="$$data" prop="avValueToOvercome" :min="0" /></div>
			<div v-show="additionalRSForAV>0">Target Armor RS: <b>{{breachArmorRS}}</b></div>
			<div v-show="additionalRSForAV>0"><b>{{roundPerc(breachArmorRSChance)}}</b>% Chance to Breach Given AV <span v-if="shooterRapidShot">({{roundPerc(breachArmorRSChanceAtLeastOnce)}}% &gt;=once, {{roundPerc(breachArmorRSChanceTwice)}}% twice)</span></div>
			<div><span class="shield-icon-inv">☗</span> With Shield? <select v-model.number="targetShield" number><option :value="0">None</option><option :value="1">Small</option><option :value="2">Medium</option><option :value="3">Large</option></select></div>
			<div v-show="targetShield!=0">Shield Position: <select v-model.number="targetShieldPosition" number><option :value="0">Low</option><option :value="1">High</option></select> <span class="shield-icon-inv">☗</span></div>
			<div v-if="targetShield > 0"><b>{{roundPerc(chanceToBypassShield)}}</b>% chance to bypass Shield alone</div>
			<div v-if="targetShield > 0"><b>{{roundPerc(chanceToBypassShield*chanceToAtLeastGraze)}}</b>% chance bypass &amp; at least Graze</div>
			<div v-if="targetShield > 0"><b>{{roundPerc(chanceToBypassShield*chanceToHitFully)}}</b>% chance bypass &amp; to Hit Fully</div>
			<div v-if="targetShield > 0 && additionalRSForAV>0"><b>{{roundPerc(chanceToBypassShield*chanceToHitFully)}}</b>% chance to bypass &amp; Penetrate given AV</div>
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
	
	var avValueToOvercome:Int = 0;
	
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

