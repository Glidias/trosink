package troshx.sos.vue.uifields;

/**
 * ...
 * @author Glidias
 */
typedef BaseUIProps = {
	@:prop({required:false, "default":null}) var label:String;
	@:prop({required:true}) var obj:Dynamic;
	@:optional @:prop({required:false, "default":false}) var disabled:Bool;
	@:prop({required:true}) var prop:Dynamic;  // prop may be integer as well to account for array index prop
}