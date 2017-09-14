package troshx.sos.core;
import troshx.core.IUid;
import troshx.sos.core.Modifier.EventModifierBinding;
import troshx.sos.core.Modifier.SituationalCharModifier;
import troshx.sos.core.Modifier.StaticModifier;


/**
 * ...
 * @author Glidias
 */
class Race implements IUid
{
	public var name:String;
	public var staticModifiers(default, null):Array<StaticModifier>;
	public var situationalModifiers(default, null):Array<SituationalCharModifier>;
	public var eventBasedModifiers(default, null):Array<EventModifierBinding>;
	
	public var magic:Bool;
	public function new(name:String) 
	{
		this.name = name;
		magic = false;
	}
	
	
	/* INTERFACE troshx.core.IUid */
	
	public var uid(get, never):String;
	
	function get_uid():String 
	{
		return name;
	}
	
}