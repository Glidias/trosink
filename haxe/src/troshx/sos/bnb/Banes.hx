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

class Bigoted extends Bane {
	public function new() {
		super("Bigoted", [5]);
	}
}

class Blind extends Bane {
	public function new() {
		super("Blind", [20]);
		flags = BoonBane.CANNOT_BE_REMOVED;
		superChannels = BoonBane.__GOOD_EYES__BAD_EYES | BoonBane.__ONE_EYED;
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
		super("Facial Deformity", [2, 4, 8]);
		flags = BoonBane.CANNOT_BE_REMOVED;
	}
}



class Frail extends Bane {
	public function new() {
		super("Frail", [8]);
		channels = BoonBane.__ROBUST_FRAIL;
		staticModifiers = [
			StaticModifier.create(Modifier.CMP_TOU, "Frail",  -1)
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
		channels = BoonBane.__ONE_EYED;
		var m:StaticModifier = StaticModifier.create(Modifier.CP, "One-Eyed", -1);
		m.next = StaticModifier.create(Modifier.MP, "One-Eyed", -2);
		staticModifiers = [m];
	}
}




class Sheltered extends Bane {
	public function new() {
		super("Sheltered", [2, 4, 6]);
		flags = BoonBane.CHARACTER_CREATION_ONLY;
		channels = (BoonBane.__TRUE_GRIT_SHELTERED); 
		this.staticModifiers = [
			StaticModifier.create(Modifier.STARTING_GRIT, "Sheltered (i)", -1),
			StaticModifier.create(Modifier.STARTING_GRIT, "Sheltered (ii)", -2),
			StaticModifier.create(Modifier.STARTING_GRIT, "Sheltered (iii)", -3)
		];
	}
}

class Short extends Bane {
	public function new() {
		super("Short", [8, 15]);
		channels = BoonBane.__TALL__SHORT;
		var m:StaticModifier = StaticModifier.create(Modifier.REACH, "Short (i)", -1);
		m.next = StaticModifier.create(Modifier.CMP_MOB, "Short (i)", -1);
		// exhaustion speed by 1x? reduced 
		
		var m2:StaticModifier = StaticModifier.create(Modifier.REACH, "Short (ii)", -2);
		m2.next = StaticModifier.create(Modifier.CMP_MOB, "Short (ii)", -2);
		
		this.staticModifiers = [
			m,
			m2
		];
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