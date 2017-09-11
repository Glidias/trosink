package troshx.sos.bnb;
import troshx.sos.core.BoonBane;
import troshx.sos.core.BoonBane.Boon;
import troshx.sos.core.Modifier;
import troshx.sos.core.Modifier.StaticModifier;

/**
 * ...
 * @author Glidias
 */
class Boons
{

	function new() 
	{
		Follower;
		ImpressiveVoice;
		Language;
		Literate;
		Allies;
		Favor;
	}
	
}
class BoonNotesAssign extends BoonAssign {  // general filler notes
	public var notes:String = "";
	public function new() {
		super();
	}
}


class Ambidextrous extends Boon {
	public function new() {
		super("Ambidextrous", [3]);
		flags = BoonBane.CHARACTER_CREATION_ONLY;
	}
}
class AnimalAffinity extends Boon {
	public function new() {
		super("Animal Affinity", [2, 4, 6]);
	}
}

class Beautiful extends Boon {
	public function new() {
		super("Beautiful", [3, 6]);
	}
}

class Berserker extends Boon {
	public function new() {
		super("Berserker", [8, 12]);
		this.staticModifiers = [StaticModifier.create(Modifier.CP, 4 )];
		// ..see manual
	}
}

class Bloodthirsty extends Boon {
	public function new() {
		super("Bloodthirsty", [4]);
	}
}

class Brave extends Boon {
	public function new() {
		super("Brave", [3]);
	}
}

class Contacts extends Boon {
	public function new() {
		super("Contacts", [1, 4, 6, 8]);
	}
}

class DirectionSense extends Boon {
	public function new() {
		super("Direction Sense", [3]);
	}
}

class Estate extends Boon {
	
	public static inline var WEALTH_PER_QTY:Int = 2;
	
	public function new() {
		super("Estate", [10]);
		flags = BoonBane.CHARACTER_CREATION_ONLY;
		multipleTimes = BoonBane.TIMES_VARYING;
	}
}

class Famous extends Boon {
	public function new() {
		super("Famous", [2, 4]);
	}
}

class FolksBackHome extends Boon {
	public function new() {
		super("Folks Back Home", [3, 6, 8]);
		
	}
}

class GoodEars extends Boon {
	public function new() {
		super("Good Ears", [3]);
		channels = BoonBane.__GOOD_EARS_BAD_EARS;
		
	}
}

class GoodEyes extends Boon {
	public function new() {
		super("Good Eyes", [3]);
		channels = BoonBane.__GOOD_EYES__BAD_EYES;
	}
}
	
class GoodNose extends Boon {
	public function new() {
		super("Good Nose", [3]);
		channels = BoonBane.__GOOD_EARS_BAD_NOSE;
	}
}

class HaleAndHearty extends Boon {
	public function new() {
		super("Hale and Hearty", [2, 4]);
	}
}

class KnownForVirtue extends Boon {
	public function new() {
		super("Known for Virtue", [5]);
	}
}

class NaturalBornKiller extends Boon {
	public function new() {
		super("Natural Born Killer", [6, 12, 18]);
		this.staticModifiers = [
			StaticModifier.create(Modifier.CP, 1 ),
			StaticModifier.create(Modifier.CP, 2 ),
			StaticModifier.create(Modifier.CP, 3 )
		];
	}
}

class NaturalLeader extends Boon {
	public function new() {
		super("Natural Leader", [3]);
	}
}

class Tall extends Boon {
	public function new() {
		super("Tall", [8, 12]);
		flags = BoonBane.CHARACTER_CREATION_ONLY;
		channels = BoonBane.__TALL__SHORT;
		this.staticModifiers = [
			null,
			StaticModifier.create(Modifier.REACH, 1) 
		];
	}
}

class TrueGrit extends Boon {
	public function new() {
		super("True Grit", [2, 4, 6]);
		flags = BoonBane.CHARACTER_CREATION_ONLY;
		channels = (BoonBane.__SHELTERED | BoonBane.__TRUE_GRIT);
		this.staticModifiers = [
			StaticModifier.create(Modifier.STARTING_GRIT, 1),
			StaticModifier.create(Modifier.STARTING_GRIT, 2),
			StaticModifier.create(Modifier.STARTING_GRIT, 3)
		];
	}
}

class Rich extends Boon {
	public function new() 
	{
		super("Rich", [1, 3, 5]);
		channels = BoonBane.__RICH__POOR;
		flags = BoonBane.CHARACTER_CREATION_ONLY;
		staticModifiers = [
			StaticModifier.create(Modifier.STARTING_MONEY, 0, 1.1),
			StaticModifier.create(Modifier.STARTING_MONEY, 0, 1.5),
			StaticModifier.create(Modifier.STARTING_MONEY, 0, 2)
		];
	}
}

class Robust extends Boon {
	public function new() {
		super("Robust", [8]);
		channels = BoonBane.__ROBUST_FRAIL;
		staticModifiers = [
			StaticModifier.create(Modifier.CMP_TOU, 1)
		];
	}
}