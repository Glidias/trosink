package troshx.sos.schools;

import troshx.sos.bnb.Banes.CompleteMonster;
import troshx.sos.core.BoonBane.BaneAssign;
import troshx.sos.core.Item;
import troshx.sos.core.Money;
import troshx.sos.core.School;
import troshx.sos.sheets.CharSheet;
import troshx.util.LibUtil;

/**
 * ...
 * @author Glidias
 */
class EsotericSchool extends School
{

	public function new() 
	{
		super("Esoteric School",4, 8);
	}
	
	static var TEST:CompleteMonster;  
	override public function customRequire(char:CharSheet):Bool {
		var test:CompleteMonster = (TEST != null ? TEST : (TEST = new CompleteMonster()));
		var testAssign:BaneAssign = char.banes.findById(test.uid);
		return testAssign == null || testAssign.rank == 0;
	}
	
	override public function getSchoolBonuses(charSheet:CharSheet):SchoolBonuses {
		return new EsotericSchoolBonuses();
	}
	
}

class EsotericSchoolBonuses extends SchoolBonuses {
	
	@:flag public static inline var SIMPLICITY:Int = (1<<0);
	@:flag public static inline var FLOWING_WATER:Int = (1<<1);
	@:flag public static inline var RAGING_FLAME:Int = (1<<2);
	@:flag public static inline var BITING_WIND:Int = (1 << 3);
	@:flag public static inline var STOIC_EARTH:Int = (1 << 4);
	
	@:ui({type:"SingleSelection", label:"Choose Element", labels:["Flowing Water", "Raging Flame", "Biting Wind", "Stoic Earth"], values:[SIMPLICITY|FLOWING_WATER, SIMPLICITY|RAGING_FLAME, SIMPLICITY|BITING_WIND, SIMPLICITY|STOIC_EARTH] }) public var flags:Int = SIMPLICITY|FLOWING_WATER;
	
	public function new() {
		super();
	}
	

	override public function getTags():Array<String> {
		var arr:Array<String> = [];
		var flags:Int = this.flags;
		Item.pushFlagLabelsToArr(true, "troshx.sos.schools.EsotericSchool:EsotericSchoolBonuses", true, ":flag");
		return arr;
	}
}