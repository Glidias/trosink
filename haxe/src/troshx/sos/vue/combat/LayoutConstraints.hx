package troshx.sos.vue.combat;
import troshx.util.layout.AspectConstraint;
import troshx.util.layout.LayoutItem;
import troshx.util.layout.PointScaleConstraint;

/**
 * Platform agnostic class that isn't really JS/Vue-depended (may refactor this elsewhere) 
 * for applying layout constraints for different views' LayoutItems.
 * @author Glidias
 */
class LayoutConstraints 
{
	
	public static function applyDollView(layoutItems:Array<LayoutItem>, names:Array<String>, tags:Array<String>, refWidth:Float, refHeight:Float):Void {
		for (i in 0...layoutItems.length) {
			var item:LayoutItem = layoutItems[i];
			var name:String = names[i];
			var tag:String = tags[i];
			
			if (tag == "part" || tag == "swing" || name == "enemyHandLeft" || name == "enemyHandRight" || name == "enemyStatus") {
				item.pin(PointScaleConstraint.createRelative(0.5, 0.5).scaleMaxRelative(1.5, 1.5).scaleMinRelative(0.5, 0.5))
				.aspect(AspectConstraint.createRelative(1,1).enablePreflight());
			}
			
			switch(name) {
				case "initRange": 
					item.pin(PointScaleConstraint.createRelative(0.5, 0.5).scaleMinRelative(1, 0).scaleMaxRelative(1, 1000))
					.pivot(PointScaleConstraint.createRelative(0.5, 1))
					.aspect(AspectConstraint.createRelative(1, 1).enablePreflight());		
				case "advManuever1", "advManuever2", "advManuever3", "advManuever4": 
					item.pin(PointScaleConstraint.createRelative(0.5, 0.5).scaleMinRelative(1, 0).scaleMaxRelative(1.5, 1.5))
					.pivot(PointScaleConstraint.createRelative(1, 0.5).scaleMinRelative(0.5, 0.5).scaleMaxRelative(1.5,1.5))
					.aspect(AspectConstraint.createRelative(1, 0.5));
				default:
			}
		}
	}
	
}