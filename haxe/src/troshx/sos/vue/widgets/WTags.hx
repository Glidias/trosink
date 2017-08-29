package troshx.sos.vue.widgets;

/**
 * Widget to handle various generic item tags for all class types
 * @author Glidias
 */
class WTags extends BaseItemWidget
{
	public static inline var NAME:String = "w-tags";

	public function new() 
	{
		super();
	}
	
}

/*
Tags:

- Cost 
- Unit

Flags
[ ] Strapped
[ ] Two Handed

Special (melee/ranged only... \)
[ ] Special Core flags and vars


WeaponCUstomise + CustomMelee Flags (always instantiate a CustomMelee to fill in)

------

[ ] Has variant  (MuSTUNHOLD)
Variant button? (2H/1H)  (circular depedency?)  check if variant has complehant of handedness

WeaponAttachments: []list of FLAG_IS_ATTACHMENT melee/ranged weapon attachments of IS_ATTACHABLE melee/ranged weapon attachments??
WeaponEntry:: with attached flag, MUST UNHHOLD! Disable weapon holding button


*/