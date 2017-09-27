package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import troshx.sos.core.School.SchoolBonuses;
import troshx.sos.vue.uifields.UI;

/**
 * ...
 * @author Glidias
 */
class SchoolSheetDetails extends VComponent<NoneT, SchoolSheetDetailsProps>
{
	public static inline var NAME:String = "SchoolSheetDetails";
	
	public function new() 
	{
		super();	
	}
	
	override function Components():Dynamic<VComponent<Dynamic,Dynamic>> {
		return UI.getComponents();
	}
	
	@:computed function get_uiFields():Array<Dynamic> {
		
		return bonuses.getUIFields();
	}
	
	@:computed function get_typeMap():Dynamic<String> {
		return UI.getTypeMapToComponentNames();
	}
	
	override function Template():String {
		return '
			<div class="school-sheet-bonuses" v-show="bonuses.__hasUIFields__">
				<div v-for="(li, i) in uiFields" :is="typeMap[li.type]" :obj="bonuses" v-bind="li" :key="li.prop"></div>
			</div>
		';
	}
	
}


typedef SchoolSheetDetailsProps = {
	@:prop({required:true}) var bonuses:SchoolBonuses;
}