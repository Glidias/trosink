package haxevx.vuex.examples.shoppingcart.modules;
import haxevx.vuex.core.VModule;
import haxevx.vuex.examples.shoppingcart.store.AppMutator;
import haxevx.vuex.examples.shoppingcart.store.ObjTypes;

/**
 * 
 * @author Glidias
 */
@:rtti
class Cart extends VModule<CartState>
{
	
	public function new() 
	{
		// initial state
		state = {
			added: [],
			checkoutStatus:null,
			lastCheckout:null  // why initials tate did not include hthis?
		}
	}
	
	
	// getters
	public var checkoutStatus(get, null):String;
    static function getCheckoutStatus(state:CartState):String {
		return state.checkoutStatus;
	}
	function get_checkoutStatus():String 
	{
		return getCheckoutStatus(state);
	}
	
	
	// actions
	@mutator var action:CartDispatcher<CartState>;
	
	// mutators
	@mutator var mutator:CartMutator<CartState>;
}

typedef CartState =  {
	var added:Array<Product>;
	var checkoutStatus:String;
	var lastCheckout:String;
}

class CartDispatcher<S:CartState> {
	
	@mutator var mutator:CartMutator<S>;
	
	 public function checkout<P:Array<Product>>(payload:P):Dynamic {  //S->P->Void
		return function(state:S, payload:P):Void {
			var savedCartItems:Array<Product> = state.added.concat([]);  
			mutator.checkoutRequest();
			
		}
		
		 /*
		const savedCartItems = [...state.added]
		commit(types.CHECKOUT_REQUEST)
		shop.buyProducts(
		  products,
		  () => commit(types.CHECKOUT_SUCCESS),
		  () => commit(types.CHECKOUT_FAILURE, { savedCartItems })
		)
		*/
	 }
}

class CartMutator<S:CartState> extends AppMutator<Dynamic> {
	override public function addToCart<P:ProductIdentifier>(payload:P):S->P->Void {
		
		return function(state:S, payload:P):Void {
			state.lastCheckout = null;
			
			//todo
			/*var record = state.added.find( p => p.id === payload.id)
			if (!record) {
			  state.added.push({
				id,
				quantity: 1
			  })
			} else {
			  record.quantity++
			}
			*/
		}
	}

}