package troshx.sos.vue.uifields;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.sheets.CharSheet.WealthAssetAssign;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class WealthAssetField extends VComponent<NoneT, WealthAssetFieldProps>
{
	public static inline var NAME:String = "WealthAssetField";
	
	public function new() 
	{
		super();
	}
		
	@:computed inline function get_current():WealthAssetAssign {
		return LibUtil.field(obj, prop);
	}
	
	@:computed function get_residueWealth():Int {
		var cw = current.worth;
		return remainingWealth!= null ? remainingWealth + cw : 999;
	}
	
	override function Template():String {
		return '<div class="wealth-asset-row">
			<label>Name: <input type="text" v-model="current.name"></input></label>
			<label>Worth: <select :disabled="fixedWorth" number v-model.number="current.worth">
					<option :value="1" :disabled="residueWealth < 1">1W</option>
					<option :value="2" :disabled="residueWealth < 2">2W</option>
					<option :value="3" :disabled="residueWealth < 3">3W</option>
				</select>
			</label>
			<label>Liquidate? <input type="checkbox" v-model="current.liquidate"></input></label>
		</div>';
	}
	
}


typedef WealthAssetFieldProps = {
	>BaseUIProps,
	@:prop({required:false, 'default':false}) @:optional var fixedWorth:Bool;
	@:prop({required:false}) @:optional var remainingWealth:Int;
}