package troshx.sos.vue;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.vue.input.MixinInput;

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
	
	@:computed function get_shooterTotalMP():Int {
		return  this.shooterProf  + this.aimBonus + this.shooterMiscMPMod;
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
	
	
	override public function Template():String {
		return '<div>
			<h1>Firing Range Viability Calculator</h1>
			<h4>Shooter</h4>
			<div><label>Profeciency Level: <InputInt :obj="$$data" prop="shooterProf" :min="0" /></label></div>
			<div><label>Aim Phases (Max 3 phases x2 MP): <InputInt :obj="$$data" prop="shooterAim" :min="0" :max="3" /></label> <b><i>{{ aimBonus }}</i></b></div>
			<div><label>Misc MP Mod: <InputInt :obj="$$data" prop="shooterMiscMPMod"  /></label></div>
			<div>Total MP: <b>{{ shooterTotalMP }}</b></div>
			<div><label><input type="checkbox" v-model="shooterRapidShot"></input> Rapid Shot?</label> <i>(Half Aim Bonus)</i></div>
			<div><label>Weapon/Firer Range Band (yards): <InputInt :obj="$$data" prop="shooterRange" :min="1" /></label></div>
			<div><label>Effective Weapon Damage: <InputInt :obj="$$data" prop="shooterDamage"  /></label></div>
			
			<h4>Target</h4>
			<div><label>Misc RS Modifier: <InputInt :obj="$$data" prop="targetMiscRSMod"  /></label></div>
			<div><label>Behaviour RS: <InputInt :obj="$$data" prop="targetBehaviourRS"  /></label></div>
			<div><label>Environmental Cover RS:</label> <select number v-model.number="targetCoverRS"><option :value="li.value" :key="i" v-for="(li, i) in coverOptions">{{ li.label }} ({{li.value}})</option></select></div>
			<div>Distance: <InputInt :obj="$$data" prop="targetDistance" :min="0" /><select number v-model.number="distRounding"><option v-for="(li, i) in roundingOptions" :key="i" :value="li.value">{{ li.label }}</option></select> <b>+{{targetDistanceRS}} RS</b></div>
			<div>Total RS: <b>{{ targetTotalRS }}</b></div>
			
		</div>';
	}
	
}

class RangeCalculatorData  {
	var shooterProf:Int = 1;
	var shooterAim:Int = 0 ;
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
	
	var distRounding:Int = ROUND_OFF;
	
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

