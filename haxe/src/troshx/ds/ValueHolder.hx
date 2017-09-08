package troshx.ds;

/**
 * Base ValueHolder to emulate pointers.
 * @author Glidias
 */
@:generic
class ValueHolder<T>
{
	var value:T;

	public function new(v:T) 
	{
		this.value = v;
	}
	
}