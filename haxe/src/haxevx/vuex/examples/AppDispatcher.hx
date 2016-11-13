package haxevx.vuex.examples;


import haxevx.vuex.core.IVxStore;
import haxevx.vuex.core.IVxStoreContext;
import js.Promise;



/**
 * ...
 * @author Glidias
 */
@:rtti
class AppDispatcher
{
	// mutators can be injected into action dispatchers
	@mutator private var appMutator:AppMutator;
	
	// dispatch helper methods
	public function moveToAsync<T>(position:{ x : Int,  y : Int }, ?context:IVxStoreContext<T>):Promise<Bool>  {
		return moveToAsync_handler(context, position);
	}
	
	public function temporaryATM<T>(position:{ x : Int,  y : Int }, ?context:IVxStoreContext<T>):Promise<Bool>  {
		return EMPTY_HANDLER_PROMISE(context, position);
	}
	
	
	//-------------------------
	
	// Consider, factor out specific app handlers to seperate class fuile, put as reference in metadata
	
	// action handlers
	function moveToAsync_handler<T>(context:IVxStoreContext<T>, position:{ x : Int,  y : Int }):Promise<Bool>  {
		
		return new Promise( function(resolve, reject):Void {
			appMutator.moveTo(position);
			resolve(true);
		}
		);  // promise
	}
	
	// ---------------------
	
	// testing/ mock handlers
	
	//
	function EMPTY_HANDLER<T>(context:IVxStoreContext<T>, payload:Dynamic=null):Void  {}
	function EMPTY_HANDLER_PROMISE<T, R>(context:IVxStoreContext<T>, payload:Dynamic=null):Promise<Bool>  {
		return new Promise( function(resolve, reject):Void {	
			resolve(false);
		}
		);
	}

	
	
}