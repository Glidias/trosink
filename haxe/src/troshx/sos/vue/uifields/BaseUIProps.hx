package troshx.sos.vue.uifields;

/**
 * ...
 * @author Glidias
 */
typedef BaseUIProps = {
	@:prop({required:false, "default":null}) var label:String;
	@:prop({required:true}) var obj:Dynamic;
	@:prop({required:true}) var prop:String;
}