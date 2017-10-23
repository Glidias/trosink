package troshx.sos.vue.input;

/**
 * ...
 * @author Glidias
 */
typedef BaseInputProps = {
	@:prop({required:true}) var obj:Dynamic;
	@:prop({required:true}) var prop:Dynamic;  
	@:prop({required:false, 'default':false }) var disabled:Bool;  
	@:prop({required:false, 'default':false }) var readonly:Bool;  
}