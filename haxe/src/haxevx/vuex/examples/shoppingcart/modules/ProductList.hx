package haxevx.vuex.examples.shoppingcart.modules;
import haxevx.vuex.core.VModule;
import haxevx.vuex.examples.shoppingcart.store.AppMutator;
import haxevx.vuex.examples.shoppingcart.store.ObjTypes;

/**
 * 
 * @author Glidias
 */
@:rtti
class ProductList extends VModule<ProductListing>
{
	// initial state
	public function new() 
	{
		state = new ProductListing();
	}

	// getters
	public var allProducts(get, null):Array<Dynamic>;
	function get_allProducts():Array<Dynamic> 
	{
		return getAllProducts(state);
	}
	static function getAllProducts(state:ProductListing):Array<Dynamic> {
		return state.all;
	}
	
	// actions
	
	
	// mutations
	@mutator var mutator:ProductListMutator<ProductListing>; 
	
}

class ProductListing {
	public var all:Array<ProductInStore> = [];
	public function new() {
		
	}
}

class ProductListMutator<S:ProductListing> extends AppMutator<Dynamic> {
	override public function receiveProducts<P:Array<ProductInStore>>(payload:P):S->P->Void {
		return function(state:S, payload:P):Void {
			state.all = payload;
		};
	}
	
	override public function addToCart<P:ProductIdentifier>(payload:P):S->P->Void {
		return function(state:S, payload:P):Void {
			var filtered = state.all.filter( function(p) { return p.id == payload.id;  } );
			if (filtered.length > 0) {
				filtered[0].inventory--;
			}
			//state.all.find(p => p.id === id).inventory--
		};
	}
	
}