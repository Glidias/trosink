package troshx.components;


/**
 * Stuff typical to all TROS bouts to manage linked combatants and store tempo/progress of bout among all combatants
 * @author Glidias
 */
class Bout<C>
{

	public inline function setStep(s:Int) 
	{
		this.s = s;
	}
	
	// for internal use for any game controller if needed
	public var c(default, null):Int = 0;
	public var s(default, null):Int = 0;
	// The standard tros convention of rounds and half tempos
	public var secondTempo(default, null):Bool = false;
	public var roundCount(default, null):Int = 0;
	public static inline var STEP_NEXT:Int = 0;
	public static inline var STEP_NEW_CYCLE:Int = 1;
	public static inline var STEP_NEW_ROUND:Int = 2;
	
	public var combatants(default, null):Array<FightNode<C>> = [];
	// post initialized linked list of GraphLinks to link FightNodes
	public var links(default, null):FightLink<C>;
	public var linkUpdateCount(default, null):Int = 0;
	
	public function new() 
	{
		
	}
	
	// Setup basic opposition links (from scratch) between combatants in array (assumed different node sideIndex refers to opposing enemies..)
	public function setupAllNewSideLinks():Void {
		var n:FightLink<C> = null;
		for (a in 0...combatants.length) {
			for (b in (a + 1)...combatants.length) {
				if (combatants[a].sideIndex != combatants[b].sideIndex) {
					if (n != null) {
						n = n.next = new FightLink<C>(combatants[a], combatants[b]);
					}
					else {
						n = links = new FightLink<C>(combatants[a], combatants[b]);
					}
				}
			}
		}
		linkUpdateCount++;
	}
	
	// On the fly addition of new combatants and auto-linking if necessary
	public function pushNewFightNode(node:FightNode<C>):Void {
		var l:FightLink<C> = null;
		var gotUpdateLinks:Bool = false;
		if (node.targetLink == null) { // auto-link any opponent if no targetLink available
			for (a in 0...combatants.length) {
				var candidate = combatants[a];
				if (candidate.sideIndex != node.sideIndex) {
					node.targetLink = l = new FightLink<C>(node, candidate);
					//node.targetLinkUpdateCount++;
					if (candidate.targetLink == null) {	// shared link if no targetLink found as well on opponent
						candidate.targetLink = l;
						//candidate.targetLinkUpdateCount++;
					}
					if (links != null) {
						l.next = links;
					}
					links = l;
					gotUpdateLinks = true;
				}
			}
		}
		
		if (gotUpdateLinks) {
			linkUpdateCount++;
		}
		combatants.push(node);
	}
	
	function clearLinksWithCondition(cond:FightLink<C>->Bool):Bool {
		var n = links;
		var gotChange:Bool = false;
		var next:FightLink<C>;
		var last:FightLink<C> = null;
		while ( n != null) {
			next = n.next;
			if (cond(n)) {
				gotChange = true;
				if (last != null) {
					last.next = next;
				} else {
					links = next;
				}
				if (n.a.targetLink == n) {
					n.a.targetLink = null;
					//n.a.targetLinkUpdateCount++;
				}
				if (n.b.targetLink == n) {
					n.b.targetLink = null;
					//n.b.targetLinkUpdateCount++;
				}
			}
			
			last = n;
			n = next;
		}
		if (gotChange) {
			linkUpdateCount++;
		}
		return gotChange;
	}
	
	public function findLink(a:FightNode<C>, b:FightNode<C>):FightLink<C> {
		var n = links;
		while (n != null) {
			if ( (n.a == a && n.b == b) || (n.b == a && n.a == b) ) {
				return n;
			}
			n = n.next;
		}
		return null;
	}
	
	public function findLinkedOpponents(a:FightNode<C>):Array<FightNode<C>> {
		var arr:Array<FightNode<C>>  = [];
		var n = links;
		while (n != null) {
			if ( (n.a == a || n.b == a)  ) {
				arr.push(n.a != a ? n.a : n.b);
			}
			n = n.next;
		}
		return arr;
	}
	
	public function countLinkedOpponents(a:FightNode<C>):Int {
		var count:Int = 0;
		var n = links;
		while (n != null) {
			if ( (n.a == a || n.b == a)  ) {
				count++;
			}
			n = n.next;
		}
		return count;
	}
	
	
	public function removeLinksFromAgainst(from:FightNode<C>, against:Array<FightNode<C>>):Bool {
		return clearLinksWithCondition(function(c) {
			return (
			c.a == from ? against.indexOf(c.b) >= 0 
			: c.b == from ? against.indexOf(c.a) >= 0 : 
			false);
		});
	}
	
	public function purgeDeadLinks():Bool {
		return clearLinksWithCondition(function(c) {
			return c.a.fight.dead || c.b.fight.dead;
		});
	}
	
	public inline function step(stepAction:Int):Void {
		if (stepAction == STEP_NEXT) {
			s++;
		}
		else if (stepAction == STEP_NEW_CYCLE) {
			s = 0;
			c++;
		} else if (stepAction == STEP_NEW_ROUND) {
			s = 0;
			c = 0;
			roundCount++;
		}
	}
	
}

class FightNode<C> { 
	public var fight:FightState;
	public var sideIndex:Int;
	public var label:String;
	
	public var charSheet:C;
	
	// focusing target link if needed
	public var targetLink:FightLink<C>;
	//public var targetLinkUpdateCount:Int = 0;
	
	public inline function getTargetOpponent():FightNode<C> {
		return targetLink != null ? targetLink.a != this ? targetLink.a : targetLink.b 
				: null;
	}
	
	public function new(label:String, charSheet:C, side:Int=0) {
		this.label = label;
		this.charSheet = charSheet;
		fight = new FightState();
		sideIndex = side;
	}
}

class FightLink<C> {
	public var a(default, null):FightNode<C>;
	public var b(default, null):FightNode<C>;
	public var reach:Int = 0; // if needed by game system, set reach between specific opponents
	public var next:FightLink<C>;
	
	public function new(a:FightNode<C>, b:FightNode<C>) {
		this.a = a;
		this.b = b;
		
		#if js
		// Make specific fields non-reactive
		
		// Keep linked list clean for Vue/javascript
		untyped Object.defineProperty(this, "next", { 
			enumerable:false,
			iterable:false,
			writable: true,
			configurable: false
		});
	
		// a and b fields are immutable upon initliazation and should not change
		untyped Object.defineProperty(this, "a", { 
			enumerable:false,
			iterable:false,
			writable: false,
			configurable: false
		});
		untyped Object.defineProperty(this, "b", { 
			enumerable:false,
			iterable:false,
			writable: false,
			configurable: false
		});
		#end
	}
}