package troshx.sos.vue.combat;
import troshx.util.layout.AspectConstraint;
import troshx.util.layout.BorderConstraint;
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
				item.pin(PointScaleConstraint.createRelative(0.5, 0.5))
				.aspect(AspectConstraint.createRelative(1,1).enablePreflight());
			}
			
			var footMiddleOffset:Float = 0.06;
			switch(name) {
				case "initRange": 
					item.pin(PointScaleConstraint.createRelative(0.5, 0.5).scaleMinRelative(1, 0))
					.pivot(PointScaleConstraint.createRelative(0.5, 1))
					.aspect(AspectConstraint.createRelative(1, 1).enablePreflight());		
				case "advManuever1", "advManuever2", "advManuever3", "advManuever4": 
					item.pin(PointScaleConstraint.createRelative(0.5, 0.5).scaleMinRelative(0.5, 0).scaleMaxRelative(2.0, 0))
					.pivot(PointScaleConstraint.createRelative(1, 0.5).scaleMinRelative(0.5, 0.5).scaleMaxRelative(1.5,1.5))
					.aspect(AspectConstraint.createRelative(1, 0.98));
				case "btnBlock", "btnVoid", "btnParry": 
					item.pin(PointScaleConstraint.createRelative(0.5, 0.5).scaleMaxRelative(1.75, 0))
					.pivot(PointScaleConstraint.createRelative(name != "btnParry" ? 1 : 0, 1).scaleMinRelative(0.5,0.5) )
					.aspect(AspectConstraint.createRelative(1, 1));
				case "opponentSwiper":
					item.pivot(PointScaleConstraint.createRelative(0, 0).scaleMinRelative(0, 0.5));
				case "roundCount":
					item.pivot(PointScaleConstraint.createRelative(0, 0).scaleMinRelative(0, 0.5));
				case "vitals":
					item.pin(PointScaleConstraint.createRelative(0,0).scaleMinRelative(0, 0.5))
					.pivot(PointScaleConstraint.createRelative(0, 0).scaleMinRelative(0.5, 0.5).scaleMaxRelative(3, 3));
				case "cpMeter":
					item.pin(PointScaleConstraint.createRelative(0,0).scaleMinRelative(0.5, 0.5).scaleMaxRelative(3, 3))
					.pivot(PointScaleConstraint.createRelative(0, 0).scaleMaxRelative(2.25, 0));
				case "cpText":
					item.pin(PointScaleConstraint.createRelative(0,0).scaleMinRelative(0.5, 0.5).scaleMaxRelative(2.25, 3))
					.pivot(PointScaleConstraint.createRelative(0, 1).scaleMinRelative(0.5, 0.5).scaleMaxRelative(1, 1.1));
				case "handLeftAlt", "handRightAlt": 
					item.pin(PointScaleConstraint.createRelative(0.5+footMiddleOffset*(name=='handLeftAlt' ? -1 : 1), 1).scaleMaxRelative(1,1))
					.pivot(PointScaleConstraint.createRelative( (name == "handLeftAlt" ? 1 : 0), 1).scaleMaxRelative(1.0, 1.1))
					.aspect(AspectConstraint.createRelative(1.0, 0));
				case "handLeftText", "handRightText": 
					item.pin(PointScaleConstraint.createRelative(0.5+footMiddleOffset*(name=='handLeftText' ? -1 : 1), 1).scaleMaxRelative(1,1))
					.pivot(PointScaleConstraint.createRelative( (name == "handLeftText" ? 1 : 0), 1).scaleMaxRelative(0, 1.2))
					;
					if (name == "handLeftText") {
						item.border(BorderConstraint.SIDE_LEFT, 0, 1);
						item.border(BorderConstraint.SIDE_RIGHT, 0, 1.1, 0.5+footMiddleOffset*(-1));
						
					} else {
						item.border(BorderConstraint.SIDE_RIGHT, 0, 1);
						item.border(BorderConstraint.SIDE_LEFT, 0, 1.1, 0.5+footMiddleOffset*(1));
					}
					
				
			}
		}
	}
	
}