package haxevx.vuex.examples;
import haxevx.vuex.examples.AppMutator.SomethingPayload;
import haxevx.vuex.examples.AppStore.AppState;

/**
 * An attempt tryout. Example AppMutator and assosiated helper methods
 * 
 * By convention, all public static method declarations in AppMutator class will be retrieved
 * to relavant VueX Store mutators during runtime initialization, using a unqiue property key derived from the
 * Class_function name string of each registered app mutator class. THe string key is used as a type for MutatorFactory.getMutatorCommit(type),
 * and once the factory commit method is generated, it replaces the relavant class method declarations to use the factory method instead.
 * Thus, AppMutator method calls during runtime (in VueJS), actually calls the matching MutatorFactory dynamically generated commit method!
 *
 * The coder need only to write AppMutator.mutatorMethod(paylaod) in his application to trigger the relavant mutations accordingly for his App state.
 * THus, no additional boilerplate code is required (or ...mapMutators JS object spread features) is required for calling "commit(someConstantString)". 
 * Additionally,  you get the necessary type-safety for explicitly type-defined mutator/action methods besides not  having to manage/sync constant strings.
 * Just define the static Mutator/Action methods within the helper classes and call them from within VxComponents,
 * after the Vue store/components are initialized, and this will trigger the necessary operations accordingly!
 * 
 * @author Glidias
 */

@:rtti
typedef SomethingPayload = {
	@:optional var count:Int;
	var name:String;
}


@:rtti 
class Helpers {
	
	// helper methods  may be inlined, but NEVER AppMutator methods!
	public static inline function Move(x:Int=0, y:Int=0, context:Dynamic = null):Void {
		AppMutator.moveTo({x:x, y:y}, context);
	}
}
 
@:rtti
class AppMutator
{
	public var testTypeDef:SomethingPayload;
	
	
	public function test():Void {
		var mypayload:SomethingPayload = {name:"rete"};
		doSomethingSpecial(mypayload);
		
		doSomething(3);
		
		Helpers.Move(4, 2);
	}
	
	public static function doSomething<S:AppState>(payload:Int, context:Dynamic=null):S->Int->Void {
		return function(state:S, payload:Int):Void  {
			state.value = payload;
		}
	}
	
	
	public static function moveTo<S:AppState, P: { x : Int,  y : Int }>(position:P, context:Dynamic = null):S-> P->Void {
		return function(state:S, payload:P):Void  {
			state.value = position.y;
		}
	}
	
	public static function doSomethingSpecial<S:AppState, P:SomethingPayload>(payload:P, context:Dynamic=null):S->P->Void {
		return function(state:S, payload:P):Void  {
			state.value = payload.count != null ? payload.count : 0;
		}
	}
	
}