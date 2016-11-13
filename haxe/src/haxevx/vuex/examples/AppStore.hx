package haxevx.vuex.examples;
import haxevx.vuex.core.VxStore;

/**
 * Example Flux (Vuex) store/module and accompanying state.
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
	
	// todo: figure out a way to implement store.getters implemetation for Vuex and Haxe...
	

	// IMPORTANT!
	// Reflect any mutators and actions for Vuex store/module to implement. 
	// Note the metadata below.
	// Multiple instances of mutator/action meta data fields can be used, so long as they are non-derived classes between one another.
			//@mutator var mutate:AppMutator; // mutate3D overwrites this! 
	@mutator var mutate3D:AppMutator3D; 
	@action var action:AppDispatcher;
	
	
	public function new() 
	{
		super();
		
		//TODO: constructor should be depciated in favour for hook methods, since some VxStores may exists as modules with on-demand created states.
		state = {
			value:2,
			matrixAB:null,
			coordinates:null,
			position: {x:20, y:20, z:0}
		}
		
	
	}
	
}

