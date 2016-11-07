package haxevx.vuex.examples;
import haxevx.vuex.core.VxStore;

/**
 * Example Flux (Vuex) store and accompanying state.
 * 
 * The T type (for sTore's sTate), can be a typedef or class, but normally, for VueJS and other typical JS flux frameworks, 
 * they encourage using plain objects due to ease of serialization, so a typedef defining required parameter constraints would suffice.
 * 
 * If you use a Class, ensure all stateful variables are initialized with "proper/typical" values upon construction.
 * Uninitialized variables (ie. variables only initialized within prototype), will NOT be reactive! THe good thing about a typedef in particular,
 * (unlike a Class), is that a typedef enforces the coder to clearly define compulsory intiailziation values, thus ensuring they are all reactive!
 * WIth classes, there's a danger of missing out on initialization of reactive properties for VueJS if you missed out initializing values for those variables. 
 * (Is there a Haxe macro to help auto-initialize class instance variable declarations?)
 * 
 * @author Glidias
 */
@:rtti
class AppStore extends VxStore<AppState>
{

	public function new() 
	{
		super();
		
		// necessary? constructor should be depciated in favour for hook methods? Nah....
		state = {
			value:2,
			matrixAB:null,
			coordinates:null
		}
		
		// todo: methods to hook up static classes to reflect Mutator/Action methods that match the Store's state Type into current Store instance.
		// SHould this be done within the constructor or outside it? Outside it seems more flexible with Store considering own self's data only..
		AppMutator;
		//AppAction;
	}
	
}

