package troshx.ds;

/**
 * ...
 * @author Glidias
 */
interface IUpdateWith<W>
{
	public function updateAgainst(ref:W):Void;
	public function spliceAgainst(ref:W):Int;
}