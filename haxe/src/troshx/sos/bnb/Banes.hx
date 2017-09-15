package troshx.sos.bnb;
import troshx.sos.core.Modifier;
import troshx.sos.core.Modifier.StaticModifier;
import troshx.sos.macro.MacroUtil;
import troshx.sos.sheets.CharSheet;
import troshx.sos.core.BoonBane.Bane;
import troshx.sos.core.BoonBane;
import troshx.sos.core.Modifier.SituationalCharModifier;
/**
 * ...
 * @author Glidias
 */
class Banes
{
	function new() 
	{
		BadEyes;
		BrainDamage;
		CrippledLimb;
		BrokenLimb;
		Debt;
		LastingPain;
		OldWound;
		SeveredLimb;
	}	
	
	public static function getList():Array<Bane> {
		return MacroUtil.getAllCurrentPackageInstancesInArray("troshx.sos.core.Bane");
	}
	
}
class BaneNotesAssign extends BaneAssign { // general filler notes
	@:ui({type:"textarea"}) public var notes:String = "";
	public function new() {
		super();
	}
}

class ArrowMagnet extends Bane {
	public function new() {
		super("Arrow Magnet", [3]);
	}
}

class BadEars extends Bane {
	public function new() {
		super("Bad Ears", [2, 4]);
		channels = BoonBane.__GOOD_EARS_BAD_EARS;
		flags = BoonBane.CANNOT_BE_REMOVED;
	}
}


class BadReputation extends Bane {
	public function new() {
		super("Bad Reputation", [3, 6, 9]);
	}
}

class BarrenOrSterility extends Bane {
	public function new() {
		super("Barren/Sterility", [1, 3]);
		flags = BoonBane.CANNOT_BE_REMOVED;
		conditions = [null, canBeEunich];
	}
	
	public static function canBeEunich(char:CharSheet, qty:Int):Bool {
		return char.gender == CharSheet.GENDER_MALE;
	}
	
}

class Bigoted extends Bane {
	public function new() {
		super("Bigoted", [5]);
	}
}

class Blind extends Bane {
	public function new() {
		super("Blind", [20]);
		flags = BoonBane.CANNOT_BE_REMOVED;
		channels = BoonBane.__BLIND__ONE_EYED_BANE | BoonBane.__GOOD_EYES__BAD_EYES;
		
	}
}

class Braggart extends Bane {
	public function new() {
		super("Braggart", [3]);
	}
}

class CompleteMonster extends Bane {
	public function new() {
		super("Complete Monster", [10]);
		channels = BoonBane.__HONORABLE__COMPLETE_MONSTER;
	}
}

class Craven extends Bane {
	public function new() {
		super("Craven", [4, 8]);
		channels = BoonBane.__CRAVEN__HONORABLE;
	}
}

class Enemies extends Bane {
	public function new() {
		super("Enemies", [3, 10, 15]);
	}
}


class FacialDeformity extends Bane {
	public function new() {
		super("Enemies", [2, 4, 8]);
		flags = BoonBane.CANNOT_BE_REMOVED;
	}
}

class Fat extends Bane {
	public function new() {
		super("Fat", [5]);
		// -2 to endurance when determining fatque
		
		staticModifiers = [
			StaticModifier.create(Modifier.CMP_MOB, -2)
		];
	}
}


class Frail extends Bane {
	public function new() {
		super("Frail", [8]);
		channels = BoonBane.__ROBUST_FRAIL;
		staticModifiers = [
			StaticModifier.create(Modifier.CMP_TOU, -1)
		];
	}
}

class Haemophilia extends Bane {
	public function new() {
		super("Haemophilia", [8]);
		flags = BoonBane.CANNOT_BE_REMOVED;
		
		// Blood lost event needed
	}
}

class Hothead extends Bane {
	public function new() {
		super("Hothead", [3]);
	}
}

class Honorable extends Bane {
	public function new() {
		super("Honorable", [5]);
		channels = BoonBane.__HONORABLE__COMPLETE_MONSTER;
	}
}


class DirePast extends Bane
{
	public function new() 
	{
		super("Dire Past", [0]);
		// manual missing character creation only...
		flags = BoonBane.CHARACTER_CREATION_ONLY | BoonBane.CANNOT_BE_REMOVED;  
	}
	
	override function getEmptyAssignInstance(charSheet:CharSheet):BaneAssign {
		return new BaneNotesAssign();
	}
}

class Mute extends Bane {
	public function new() {
		super("Mute", [5, 8]);
		flags = BoonBane.CANNOT_BE_REMOVED;
	}
}

class OneEyed extends Bane {
	public function new() {
		super("One-Eyed", [10]);
		flags = BoonBane.CANNOT_BE_REMOVED;
		channels = BoonBane.__BLIND__ONE_EYED_BANE;
		var m:StaticModifier = StaticModifier.create(Modifier.CP, -1);
		m.next = StaticModifier.create(Modifier.MP, -2);
		staticModifiers = [m];
	}
}

class Poor extends Bane {
	public function new() {
		super("Poor", [4, 6, 8]);
		flags = BoonBane.CHARACTER_CREATION_ONLY;
		channels = BoonBane.__RICH__POOR;
		staticModifiers = [
			StaticModifier.create(Modifier.STARTING_WEALTH, 0, .5),
			StaticModifier.create(Modifier.STARTING_WEALTH, 0, .25),
			StaticModifier.create(Modifier.STARTING_MONEY, 0, 0)
		];
	}
}


class Sheltered extends Bane {
	public function new() {
		super("Sheltered", [2, 4, 6]);
		flags = BoonBane.CHARACTER_CREATION_ONLY;
		channels = (BoonBane.__SHELTERED | BoonBane.__TRUE_GRIT); 
		this.staticModifiers = [
			StaticModifier.create(Modifier.STARTING_GRIT, -1),
			StaticModifier.create(Modifier.STARTING_GRIT, -2),
			StaticModifier.create(Modifier.STARTING_GRIT, -3)
		];
	}
}

class Short extends Bane {
	public function new() {
		super("Short", [8, 15]);
		channels = BoonBane.__TALL__SHORT;
		var m:StaticModifier = StaticModifier.create(Modifier.REACH, -1);
		m.next = StaticModifier.create(Modifier.CMP_MOB, -1);
		// exhaustion speed by 1x? reduced 
		
		var m2:StaticModifier = StaticModifier.create(Modifier.REACH, -2);
		m2.next = StaticModifier.create(Modifier.CMP_MOB, -2);
		
		this.staticModifiers = [
			m,
			m2
		];
	}
}

class Skinny extends Bane {
	public function new() {
		
		super("Skinny", [3]);
		// CAR reduced by 1 hard??
	}
}

class TechnologicallyImpaired extends Bane {
	public function new() {
		super("Technologically Impaired", [5]);
	}
}

class UnhappilyMarried extends Bane {
	public function new() {
		super("Unhappily Married", [1, 2, 3]);
	}
}

class Virtuous extends Bane {
	public function new() {
		super("Virtuous", [5]);
	}
}

class Wanted extends Bane {
	@:level public static inline var ALIVE:Int = 1;
	@:level public static inline var DEAD:Int = 2;
	@:level public static inline var ALIVE_ALIVE:Int = 3;
	
	public function new() {
		super("Wanted", [5, 10, 15]);
	}
}