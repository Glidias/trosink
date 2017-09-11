package troshx.sos.vue.uifields;
import troshx.sos.core.BodyChar;

typedef HitLocationProps = {
	>BaseUIProps,
	@:prop({required:true}) var body:BodyChar;
	
}