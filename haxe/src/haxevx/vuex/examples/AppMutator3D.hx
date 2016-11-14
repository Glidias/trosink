package haxevx.vuex.examples;
import haxe.io.Path;
import haxevx.vuex.examples.AppMutator.SomethingPayload;
import haxevx.vuex.examples.AppMutator3D.MyOwnState;

/**
 * Example mutator class module (extending from a root mutator class) explaining the various approaches to declaring mutator commit+handler  methods 
 * with strict typing, balancing the need for (at least) some boilerplate at times to ensure type safety.
 * @author Glidias
 */
class AppMutator3D extends AppMutator
{
	
	// Implement any helpers to call committers.

	public inline function Move3D(x:Int=0, y:Int=0,z:Int):Void { 	// Helper methods may be inlined. But NOT mutator methods! Becareful!
		moveTo3D({x:x, y:y, z:z});
	}
	
	// Implement commit-handlers below.

	// APPROACH #1:
	// This approach below allows for mutation of dynamic/overridable state types for any extended mutator classes extending this function
	// Simply return a non-anonymous function handler reference (would require a bit more boilerplate), in order to allow for 
	// runtime initialization type checkings for a given store module's dynamic state type, depending on where this mutator method is registered to which store
	// (since different store modules may have different state data types, this is hard to predict during compile time).
	// If an inline annoymous function is returned, you lose runtime type-checking against a store module's state type, and so inlining anonymous methods 
	// within the commit method body should NOT be done, as you lose runtime init type-checking over the state that will be mutated within a given store!
	 override public function moveTo< P: { x : Int,  y : Int }>(payload:P):Dynamic-> P->Void { 
		 // returned handler of non-anonymous functions for reflecting state parameter to ensure it matches a store module's parameter state type at runtime
		return MOVE_TO;   //  handler references should be static functions under a Class. Any class is allowed.
	}
	static function MOVE_TO(state:MyOwnState, payload:{ x : Int,  y : Int }):Void { 
		state.a = payload.x;
	}
	// If first parameter of returned function type is Dynamic, the convention above must be adopted as best practice (ie. it uses APPROACH #1), 
	// else warnings/errors will be displayed at runtime initialization.
	
	
	// APPROACH #2:
	// The approaches below restricts/enforces a fixed state type for all mutators that extend this function.
	// As a result, you can (often/optionally) safely return an inline anonoymous function within the dispatch methods themselves 
	// without referencing another class method.
	
	// style 1: type constraint in return function parameters
	public function moveToVariantEnforceStateType<P: { x : Int,  y : Int }>(payload:P):AppState-> P->Void { 
		return function(state:AppState, payload:P):Void {
			state.value = payload.x;
		}
	}
	
	
	// style 2: type constraint S in method header for return data type
	// new mutator methods under AppMutator3D namespace
	public function moveTo3D<S:AppState, P: { x : Int,  y : Int, z:Int }>(payload:P):S-> P->Void { 
		return function(state:S, payload:P):Void  {
			state.position.x = payload.x;
			state.position.y =payload.y;
			state.position.z =payload.z;
		}
	}
	

	
}

typedef MyOwnState = {
	a:Int,
	b:Int
}