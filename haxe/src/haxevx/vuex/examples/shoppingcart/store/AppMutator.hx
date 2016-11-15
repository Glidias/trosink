package haxevx.vuex.examples.shoppingcart.store;
import haxevx.vuex.examples.shoppingcart.store.ObjTypes;

/**
 * ...
 * @author Glidias
 */
@:rtti
class AppMutator<S>
{
	
	public function addToCart<P:ProductIdentifier>(payload:P):S->P->Void {
		return null;
	}
	
	public function checkoutRequest():S->Void {
		return null;
	}
	public function checkoutSuccess():S->Void {
		return null;
	}
	public function checkoutFailure():S->Void {
		return null;
	}

	
	public function receiveProducts<P:Array<ProductInStore>>(payload:P):S->P->Void {
		return null;
	}

	
	
}