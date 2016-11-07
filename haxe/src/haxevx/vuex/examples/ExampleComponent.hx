package haxevx.vuex.examples;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VxComponent;

/**
 * Generic Type initializing approaches:
 * 
 *  RTTI  (runtime type information) is required for the Component class, always! Component classes extend from either VxComponent  (for VueX/FLux implementations)
 * or VComponent base classes accordingly (for non-flux components or components without dependence on flux store). The Compoennt class' RTTI can be used to generate VueJS components 
 * (or perhaps other web components like ReactJS components and such). 
 * Note that Component classes should not be further extended from the base classes (for now, i think this is the best practice for simplicity).
 * Deep inheritance isn't really good.
 * 
 * For both component props and data (whichever/both/none is implemented), either a RTTI class is used, or a class with structInit,  or else an inlined 
 * anoymouse type structure for the component. 
 * Note that for VueJS component Props, typedef or non-rtti classes are not allowed, unless you define a custom getNewProps() implementation to set up
 * custom starting values for VueJS to reflect and infer property types/values from.
 * 
 * RTTIProps Classes may provide metadata conventions to reflect optional properties or default values to reflect to VuejS environment,
 * if getNewProps() isn't implemented.

 * If a data/prop type isn't applicable (eg. a  Stateless component where data is N/A), use NoneT (eg. NoneT for D (data) attribute).
 * If a non-NoneT type is implemented for data, naturally getNewData() SHOULD be implemented, so a runtime warning will be shown if you don't.
 * 
 * Component classes should NOT have a constructor and have no need for one. Methods and getters are defined for VUEJS' methods and computed properties 
 * accordingly, and reflected accordingly to VueJS via the RTTI. 
 * 
 * If you want to perform customised app-specific initializations, override the empty Created() implementation
 * and write your code accordingly. This will be translated to VueJS "created" hook for Vue components. 
 * Same likewise for the other hook methods like Render(), and Template(). Override them to implement your own implementations!
 * 
 * @author Glidias
 */

 // eg. TYPEDEF PROPS
 typedef ExampleProps  =
{
	public var anonX:Float;
	public var anonY:Float;
	@:optional public var anonZ:Float;
}

// eg. CLASS PROPS
@:structInit   // may/may not be used, depends on user preference
@:rtti   // if no RTTI is used, getNewProps() must be implemented by the component instance.
class ExamplePropsClass
{
	public var anonX:Float;
	public var anonY:Float;
	@:optional public var anonZ:Float;
}

// eg. INLINED props within class type parameters
@:rtti
@:final class ExampleComponent extends VxComponent<AppStore, NoneT, {
	var anonX:Float;
	var anonY:Float;
	@:optional var anonZ:Float;
}
>
{
	override function Created():Void {
		
	}

	var exampleGetter(get, null):Float;
	function get_exampleGetter():Float 
	{
		return store.state.coordinates != null ? store.state.coordinates[0] : 0;
	}

	function exampleMethod():Void {
		
	}
	
	
}