package troshx.ds;

/**
 * @author Glidias
 */
interface IMatchArray<T>
{
	public function add(item:T):Void;
	public function delete(item:T):Void;
	public function contains(item:T):Bool;
}