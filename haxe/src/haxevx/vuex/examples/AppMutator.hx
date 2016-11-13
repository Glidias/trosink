package haxevx.vuex.examples;
import haxevx.vuex.core.IVxStore;
import haxevx.vuex.examples.AppState;

/**
 * An attempt tryout. Example AppMutator and assosiated helper methods
 * 
 * By convention, all public static method declarations in AppMutator class will be retrieved
 * to relavant VueX Store mutators during runtime initialization, using a unqiue property key derived from the
 * Class_function name string of each registered app mutator class. THe string key is used as a type for MutatorFactory.getMutatorCommit(type),
 * and once the factory commit method is generated, it replaces the relavant class method declarations to use the factory method instead.
 * Thus, AppMutator method calls during runtime (in VueJS), actually calls the matching MutatorFactory dynamically generated commit method!
 *
 * The coder need only to write appMutator.mutatorMethod(paylaod) in his application to trigger the relavant mutations accordingly for his App state.
 * THus, no additional boilerplate code is required (or ...mapMutators JS object spread features) is required for calling "commit(someConstantString)". 
 * Additionally,  you get the necessary type-safety for explicitly type-defined mutator/action methods besides not  having to manage/sync constant strings.
 * Just define the static Mutator/Action methods within the helper classes and call them from within VxComponents,
 * after the Vue store/components are initialized, and this will trigger the necessary operations accordingly!
 * 
 * eg.  appMutator.moveTo( {x:2, y:24});
 * 
 * @author Glidias
 */


typedef SomethingPayload = {
	@:optional var count:Int;
	var name:String;
}


@:rtti
class AppMutator
{
	
	// HELPERS:

	// RTTI Void return data types will be treated as mutator helper methods and not inclucded into VueX store mutator;
	public inline function Move(x:Int=0, y:Int=0):Void { 	// Helper methods may be inlined. But NOT mutator methods! Becareful!
		moveTo({x:x, y:y});
	}
	
	// MUTATORS:
	
	// RTTI does include information of whether a method is inlined or not, and if so, gives a runtime critical warning for Mutator methods!
	// Consider, factor out return handlers to seperate class file? 
	
	public function doSomething<S:AppState, P:Int>(payload:P):S->P->Void {
		return function(state:S, payload:P):Void  {
			state.value = payload;
		}
	}
	
	public function moveTo<S:AppState, P: { x : Int,  y : Int }>(payload:P):S-> P->Void {
		return function(state:S, payload:P):Void  {
			state.position.x = payload.x;
			state.position.y = payload.y;
		}
	}
	
	public function doSomethingSpecial<S:AppState, P:SomethingPayload>(payload:P):S->P->Void {
		return function(state:S, payload:P):Void  {
			state.value = payload.count != null ? payload.count : 0;
		}
	}
	
}