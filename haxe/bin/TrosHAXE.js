(function (console, $hx_exports) { "use strict";
$hx_exports.troshx = $hx_exports.troshx || {};
$hx_exports.troshx.tros = $hx_exports.troshx.tros || {};
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var HxOverrides = function() { };
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var Main = function() { };
Main.main = function() {
	troshx_BodyChar;
	troshx_ZoneBody;
	troshx_tros_HumanoidBody;
};
var Reflect = function() { };
Reflect.field = function(o,field) {
	try {
		return o[field];
	} catch( e ) {
		return null;
	}
};
Reflect.setField = function(o,field,value) {
	o[field] = value;
};
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
};
var haxe_IMap = function() { };
var haxe_ds_StringMap = function() {
	this.h = { };
};
haxe_ds_StringMap.__interfaces__ = [haxe_IMap];
haxe_ds_StringMap.prototype = {
	setReserved: function(key,value) {
		if(this.rh == null) this.rh = { };
		this.rh["$" + key] = value;
	}
	,keys: function() {
		var _this = this.arrayKeys();
		return HxOverrides.iter(_this);
	}
	,arrayKeys: function() {
		var out = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) out.push(key);
		}
		if(this.rh != null) {
			for( var key in this.rh ) {
			if(key.charCodeAt(0) == 36) out.push(key.substr(1));
			}
		}
		return out;
	}
};
var troshx_BodyChar = $hx_exports.troshx.BodyChar = function() {
	this.zones = [];
	this.zones[0] = null;
	this.zonesB = [];
	this.zones[1] = null;
};
troshx_BodyChar.getEmptyBodyPartTypeDef = function() {
	return { BL : 0, KD : null, lev : 0, d : 0, ko : null, shock : 0, shockWP : 0, pain : 0, painWP : 0};
};
troshx_BodyChar.getEmptyWoundLocation = function(id) {
	return { id : id, cut : [], puncture : [], bludgeon : []};
};
troshx_BodyChar.getCleanArrayOfWound = function(dirtyArr) {
	var cleanArr = [];
	var _g1 = 0;
	var _g = dirtyArr.length;
	while(_g1 < _g) {
		var i = _g1++;
		cleanArr[i] = troshx_BodyChar.getBodyPartOf(dirtyArr[i]);
	}
	return cleanArr;
};
troshx_BodyChar.getBodyPartOf = function(obj) {
	var theBodyPart = troshx_BodyChar.getEmptyBodyPartTypeDef();
	var _g = 0;
	var _g1 = Reflect.fields(theBodyPart);
	while(_g < _g1.length) {
		var f = _g1[_g];
		++_g;
		if(Object.prototype.hasOwnProperty.call(obj,f)) Reflect.setField(theBodyPart,f,Reflect.field(obj,f));
	}
	return theBodyPart;
};
troshx_BodyChar.prototype = {
	getAllWoundLocations: function() {
		var arr = [];
		var partsMap = new haxe_ds_StringMap();
		var _g = 0;
		var _g1 = Reflect.fields(this.partsCut);
		while(_g < _g1.length) {
			var f = _g1[_g];
			++_g;
			if(__map_reserved[f] != null) partsMap.setReserved(f,true); else partsMap.h[f] = true;
		}
		var _g2 = 0;
		var _g11 = Reflect.fields(this.partsBludgeon);
		while(_g2 < _g11.length) {
			var f1 = _g11[_g2];
			++_g2;
			if(__map_reserved[f1] != null) partsMap.setReserved(f1,true); else partsMap.h[f1] = true;
		}
		var _g3 = 0;
		var _g12 = Reflect.fields(this.partsPuncture);
		while(_g3 < _g12.length) {
			var f2 = _g12[_g3];
			++_g3;
			if(__map_reserved[f2] != null) partsMap.setReserved(f2,true); else partsMap.h[f2] = true;
		}
		var $it0 = partsMap.keys();
		while( $it0.hasNext() ) {
			var f3 = $it0.next();
			var woundLocation = troshx_BodyChar.getEmptyWoundLocation(f3);
			if(Object.prototype.hasOwnProperty.call(this.partsCut,f3)) woundLocation.cut = troshx_BodyChar.getCleanArrayOfWound(Reflect.field(this.partsCut,f3));
			if(Object.prototype.hasOwnProperty.call(this.partsPuncture,f3)) woundLocation.puncture = troshx_BodyChar.getCleanArrayOfWound(Reflect.field(this.partsPuncture,f3));
			if(Object.prototype.hasOwnProperty.call(this.partsBludgeon,f3)) woundLocation.bludgeon = troshx_BodyChar.getCleanArrayOfWound(Reflect.field(this.partsBludgeon,f3));
			arr.push(woundLocation);
		}
		return arr;
	}
};
var troshx_ZoneBody = function() {
	this.weightsTotal = 0;
};
troshx_ZoneBody.create = function(name,partWeights,parts,weightsTotal) {
	if(weightsTotal == null) weightsTotal = 0;
	var zb = new troshx_ZoneBody();
	zb.name = name;
	zb.parts = parts;
	zb.partWeights = partWeights;
	zb.weightsTotal = weightsTotal;
	if(weightsTotal == 0) zb.recalcWeightsTotal();
	return zb;
};
troshx_ZoneBody.prototype = {
	recalcWeightsTotal: function() {
		var accum = 0;
		var i = this.partWeights.length;
		while(--i > -1) accum += this.partWeights[i];
		this.weightsTotal = accum;
	}
	,getBodyPart: function(floatRatio) {
		floatRatio *= this.weightsTotal;
		var accum = 0;
		var result = 0;
		var _g1 = 0;
		var _g = this.partWeights.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(floatRatio < accum) break;
			accum += this.partWeights[i];
			result = i;
		}
		return this.parts[result];
	}
};
var troshx_tros_HumanoidBody = $hx_exports.troshx.tros.HumanoidBody = function() {
	troshx_BodyChar.call(this);
	this.partsBludgeon = { 'foot' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 3, 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : 1, 'BL' : 0, 'shock' : 6, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'KD' : -1, 'BL' : 1, 'shock' : 9, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1}], 'shin_and_lower_leg' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 2, 'BL' : 0, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 0, 'shock' : 6, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'KD' : -3, 'BL' : 2, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'KD' : -1, 'BL' : 5, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'knee_and_nearby_areas' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 0, 'BL' : 2, 'shock' : 8, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'KD' : -5, 'BL' : 6, 'shock' : 10, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0},{ 'KD' : -1, 'BL' : 8, 'shock' : 15, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'thigh' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'KD' : 2, 'BL' : 0, 'shock' : 5, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'KD' : 0, 'BL' : 0, 'shock' : 7, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'KD' : -4, 'BL' : 3, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'KD' : -1, 'BL' : 7, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'inner_thigh' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'KD' : 2, 'BL' : 0, 'shock' : 5, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'KD' : 0, 'BL' : 0, 'shock' : 7, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'KD' : -4, 'BL' : 3, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'KD' : -1, 'BL' : 7, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'hip' : [{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : -1, 'BL' : 2, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 10, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'BL' : 20, 'shock' : -1, 'shockWP' : 0, 'pain' : 13, 'painWP' : 1, 'd' : 1}], 'groin' : [{ 'BL' : 0, 'shock' : 7, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'ko' : 0, 'BL' : 0, 'shock' : 9, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'ko' : -2, 'BL' : 3, 'shock' : 11, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1},{ 'ko' : -1, 'BL' : 18, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0},{ 'BL' : 20, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0, 'd' : 2}], 'abdomen' : [{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'ko' : 3, 'BL' : 0, 'shock' : 7, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'ko' : 0, 'BL' : 3, 'shock' : 10, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 8, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'ko' : -3, 'BL' : 15, 'shock' : -1, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1}], 'ribcage' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'ko' : 2, 'BL' : 1, 'shock' : 8, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'ko' : 0, 'BL' : 3, 'shock' : 10, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'ko' : -3, 'BL' : 9, 'shock' : -1, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1}], 'upper_abdomen' : [{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'ko' : 3, 'BL' : 0, 'shock' : 7, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'ko' : 0, 'BL' : 3, 'shock' : 10, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 8, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'ko' : -3, 'BL' : 15, 'shock' : -1, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1}], 'chest' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'ko' : 2, 'BL' : 1, 'shock' : 8, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'ko' : 0, 'BL' : 3, 'shock' : 10, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'ko' : 0, 'BL' : 9, 'shock' : -1, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1}], 'upper_body' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'ko' : 2, 'BL' : 1, 'shock' : 8, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'ko' : 0, 'BL' : 3, 'shock' : 10, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'ko' : -3, 'BL' : 9, 'shock' : -1, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1}], 'neck' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 1, 'shock' : 7, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'ko' : 0, 'BL' : 3, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'BL' : 3, 'shock' : -1, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1},{ 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'face' : [{ 'ko' : 3, 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 0, 'painWP' : 0},{ 'ko' : 1, 'BL' : 1, 'shock' : 8, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 4, 'shock' : 10, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0},{ 'ko' : -3, 'BL' : 6, 'shock' : 12, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'lower_head' : [{ 'ko' : 3, 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 0, 'painWP' : 0},{ 'ko' : 1, 'BL' : 1, 'shock' : 8, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 4, 'shock' : 10, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0},{ 'ko' : -3, 'BL' : 6, 'shock' : 12, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'upper_head' : [{ 'ko' : 2, 'BL' : 0, 'shock' : 8, 'shockWP' : 1, 'pain' : 5, 'painWP' : 1},{ 'ko' : 0, 'BL' : 3, 'shock' : 8, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'ko' : -3, 'BL' : 4, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'BL' : 6, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'upper_arm_and_shoulder' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 5, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 1, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 5, 'shock' : 10, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'BL' : 10, 'shock' : 13, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'hand' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 0, 'painWP' : 0},{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 7, 'shockWP' : 1, 'pain' : 5, 'painWP' : 1},{ 'BL' : 1, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 3, 'shock' : 9, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1}], 'forearm' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 0, 'painWP' : 0},{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 1, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 2, 'shock' : 8, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 3, 'shock' : 10, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1}], 'elbow' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 5, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 1, 'shock' : 8, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 3, 'shock' : 9, 'shockWP' : 0, 'pain' : 10, 'painWP' : 0}]};
	this.partsCut = { 'foot' : [{ 'BL' : 0, 'shock' : 3, 'shockWP' : 1, 'pain' : 2, 'painWP' : 1},{ 'BL' : 1, 'shock' : 3, 'shockWP' : 0, 'pain' : 3, 'painWP' : 1},{ 'KD' : 3, 'BL' : 2, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 1, 'BL' : 5, 'shock' : 6, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : 0, 'BL' : 10, 'shock' : 9, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1}], 'shin_and_lower_leg' : [{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 2, 'painWP' : 1},{ 'KD' : 2, 'BL' : 2, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : -2, 'BL' : 8, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'KD' : 0, 'BL' : 13, 'shock' : 9, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1}], 'knee_and_nearby_areas' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 3, 'painWP' : 1},{ 'BL' : 2, 'shock' : 5, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 0, 'BL' : 4, 'shock' : 8, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'KD' : -5, 'BL' : 8, 'shock' : 10, 'shockWP' : 0, 'pain' : 13, 'painWP' : 1},{ 'KD' : 0, 'BL' : 13, 'shock' : 12, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'thigh' : [{ 'BL' : 1, 'shock' : 4, 'shockWP' : 1, 'pain' : 3, 'painWP' : 1},{ 'KD' : 2, 'BL' : 2, 'shock' : 2, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'KD' : 2, 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'KD' : 2, 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'KD' : 2, 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1}], 'inner_thigh' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 6, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 0, 'BL' : 9, 'shock' : 5, 'shockWP' : 0, 'pain' : 16, 'painWP' : 1},{ 'BL' : 12, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 17, 'shock' : 7, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1, 'd' : 2}], 'groin' : [{ 'BL' : 6, 'shock' : 9, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'BL' : 9, 'shock' : 9, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 12, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1, 'd' : 1},{ 'BL' : 18, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0},{ 'BL' : 20, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0, 'd' : 2}], 'hip' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 3, 'painWP' : 1},{ 'BL' : 2, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 0, 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'KD' : -2, 'BL' : 8, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'KD' : -1, 'BL' : 12, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'abdomen' : [{ 'BL' : 1, 'shock' : 2, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 3, 'shock' : 4, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 7, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 10, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'BL' : 20, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0}], 'ribcage' : [{ 'BL' : 0, 'shock' : 2, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 0, 'BL' : 3, 'shock' : 8, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 9, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'BL' : 20, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0, 'd' : 2}], 'chest' : [{ 'BL' : 0, 'shock' : 2, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 0, 'BL' : 3, 'shock' : 8, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 9, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'BL' : 20, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0, 'd' : 2}], 'upper_arm_and_shoulder' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 8, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 12, 'shock' : 13, 'shockWP' : 0, 'pain' : 14, 'painWP' : 1}], 'shoulder' : [{ 'BL' : 1, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 5, 'shock' : 6, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 10, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 25, 'shock' : 10, 'shockWP' : 0, 'pain' : 11, 'painWP' : 1}], 'neck' : [{ 'BL' : 1, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 4, 'shock' : 7, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 9, 'shock' : 10, 'shockWP' : 0, 'pain' : 11, 'painWP' : 1},{ 'BL' : 20, 'shock' : 13, 'shockWP' : 0, 'pain' : 14, 'painWP' : 1},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'face' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 0, 'painWP' : 0},{ 'BL' : 2, 'shock' : 8, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 5, 'shock' : 1, 'shockWP' : 1, 'pain' : 7, 'painWP' : 1},{ 'BL' : 7, 'shock' : 10, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'lower_head' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 0, 'painWP' : 0},{ 'BL' : 2, 'shock' : 8, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 5, 'shock' : 1, 'shockWP' : 1, 'pain' : 7, 'painWP' : 1},{ 'BL' : 7, 'shock' : 10, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'upper_head' : [{ 'BL' : 3, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 3, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 4, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'ko' : 0, 'BL' : 10, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'hand' : [{ 'BL' : 0, 'shock' : 7, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 6, 'shock' : 9, 'shockWP' : 1, 'pain' : 6, 'painWP' : 1},{ 'BL' : 8, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'BL' : 10, 'shock' : 10, 'shockWP' : 0, 'pain' : 11, 'painWP' : 1, 'd' : 1}], 'forearm' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 6, 'shock' : 8, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 12, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1, 'd' : 1}], 'elbow' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 3, 'shock' : 6, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 6, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'BL' : 12, 'shock' : 10, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1}]};
	this.partsPuncture = { 'foot' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 3, 'BL' : 2, 'shock' : 4, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : -1, 'BL' : 3, 'shock' : 7, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'KD' : -1, 'BL' : 3, 'shock' : 7, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1}], 'shin_and_lower_leg' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'KD' : 2, 'BL' : 1, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 2, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : -2, 'BL' : 2, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : 0, 'BL' : 4, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1}], 'knee_and_nearby_areas' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 5, 'painWP' : 1},{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 0, 'BL' : 3, 'shock' : 6, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : -2, 'BL' : 4, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'KD' : -5, 'BL' : 6, 'shock' : 9, 'shockWP' : 0, 'pain' : 11, 'painWP' : 1}], 'thigh' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'KD' : 2, 'BL' : 1, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'KD' : 0, 'BL' : 2, 'shock' : 5, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : -2, 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 8, 'shock' : 5, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1}], 'groin' : [{ 'BL' : 6, 'shock' : 7, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'BL' : 8, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 10, 'shock' : 10, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1},{ 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0},{ 'BL' : 15, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0}], 'hip' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 1, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'KD' : -2, 'BL' : 6, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'KD' : 0, 'BL' : 10, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'flesh_to_the_side' : [{ 'lev' : 1, 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'lev' : 1, 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'lev' : 1, 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'lev' : 1, 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'lev' : 1, 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1}], 'lower_abdomen' : [{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 6, 'shock' : 4, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 8, 'shock' : 7, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'BL' : 18, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0}], 'upper_abdomen' : [{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 8, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 10, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 13, 'shock' : 13, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1},{ 'BL' : 19, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0}], 'chest' : [{ 'BL' : 0, 'shock' : 9, 'shockWP' : 1, 'pain' : 5, 'painWP' : 1},{ 'BL' : 4, 'shock' : 4, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 8, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 19, 'shock' : 13, 'shockWP' : 0, 'pain' : 13, 'painWP' : 1, 'd' : 2},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'collar_and_throat' : [{ 'BL' : 2, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 6, 'shock' : 7, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'shock' : 13, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1},{ 'BL' : 15, 'shock' : -1, 'shockWP' : 0, 'pain' : 20, 'painWP' : 1},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'face' : [{ 'BL' : 1, 'shock' : 7, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 6, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'ko' : -3, 'BL' : 8, 'shock' : 10, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'ko' : 0, 'BL' : 19, 'shock' : 13, 'shockWP' : 0, 'pain' : 13, 'painWP' : 0},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'head' : [{ 'BL' : 1, 'shock' : 7, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 6, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'ko' : -3, 'BL' : 8, 'shock' : 10, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'ko' : 0, 'BL' : 19, 'shock' : 13, 'shockWP' : 0, 'pain' : 13, 'painWP' : 0},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'hand' : [{ 'BL' : 0, 'shock' : 6, 'shockWP' : 1, 'pain' : 5, 'painWP' : 1},{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 9, 'shockWP' : 1, 'pain' : 6, 'painWP' : 1},{ 'BL' : 5, 'shock' : 7, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'BL' : 9, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1}], 'forearm' : [{ 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 1, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 2, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 6, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 7, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1}], 'elbow' : [{ 'BL' : 0, 'shock' : 6, 'shockWP' : 1, 'pain' : 5, 'painWP' : 1},{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 3, 'shock' : 6, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 5, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'BL' : 7, 'shock' : 9, 'shockWP' : 0, 'pain' : 11, 'painWP' : 1}], 'upper_arm' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 1, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 5, 'shock' : 6, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 7, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1}]};
	this.thrustStartIndex = 8;
	this.zones[1] = troshx_ZoneBody.create("to the Lower Legs",[1,3,2],["foot","shin_and_lower_leg","knee_and_nearby_areas"]);
	this.zones[2] = troshx_ZoneBody.create("to the Upper Legs",[2,3,1],["knee_and_nearby_areas","thigh","hip"]);
	this.zones[3] = troshx_ZoneBody.create("for Horizontal Swing",[1,1,1,2,1],["hip","upper_abdomen","lower_abdomen","ribcage","arms"]);
	this.zones[4] = troshx_ZoneBody.create("for Overhand Swing",[2,1,1,1,1],["upper_arm_and_shoulder","chest","neck","lower_head","upper_head"]);
	this.zones[5] = troshx_ZoneBody.create("for Downward Swing from Above",[3,1,2],["upper_head","lower_head","shoulder"]);
	this.zones[6] = troshx_ZoneBody.create("for Upward Swing from Below",[3,1,1,1],["inner_thigh","groin","abdomen","chest"]);
	this.zones[7] = troshx_ZoneBody.create("to the Arms",[1,2,1,2],["hand","forearm","elbow","upper_arm_and_shoulder"]);
	this.zones[8] = troshx_ZoneBody.create("to the Lower Legs",[1,3,1,1],["foot","shin_and_lower_leg","knee_and_nearby_areas",""]);
	this.zones[9] = troshx_ZoneBody.create("to the Upper Legs",[2,3,1],["knee_and_nearby_areas","thigh","hip"]);
	this.zones[10] = troshx_ZoneBody.create("to the Pelvis",[2,2,2],["hip","groin","lower_abdomen"]);
	this.zones[11] = troshx_ZoneBody.create("to the Belly",[5,1],["lower_abdomen","flesh_to_the_side"]);
	this.zones[12] = troshx_ZoneBody.create("to the Chest",[2,4],["upper_abdomen","chest"]);
	this.zones[13] = troshx_ZoneBody.create("to the Head",[2,4],["collar_and_throat",["face","face","face","head","head"]]);
	this.zones[14] = troshx_ZoneBody.create("to the Arm",[1,2,1,2],["hand","forearm","elbow","upper_arm"]);
	this.zonesB[1] = troshx_ZoneBody.create("to the Lower Legs",[1,3,2],["foot","shin_and_lower_leg","knee_and_nearby_areas"]);
	this.zonesB[2] = troshx_ZoneBody.create("to the Upper Legs",[2,3,1],["knee_and_nearby_areas","thigh","hip"]);
	this.zonesB[3] = troshx_ZoneBody.create("for Horizontal Swing",[1,1,1,2,1],["hip","upper_abdomen","lower_abdomen","ribcage","arms"]);
	this.zonesB[4] = troshx_ZoneBody.create("for Overhand Swing",[2,1,1,1,1],["upper_arm_and_shoulder","upper_body","neck","lower_head","upper_head"]);
	this.zonesB[5] = troshx_ZoneBody.create("for Downward Swing from Above",[2,1,3],["shoulder","lower_head","upper_head"]);
	this.zonesB[6] = troshx_ZoneBody.create("for Upward Swing from Below",[3,1,1,1],["inner_thigh","groin","abdomen","lower_head"]);
	this.zonesB[7] = troshx_ZoneBody.create("to the Arms",[1,2,1,2],["hand","forearm","elbow","upper_arm_and_shoulder"]);
	this.zonesB[8] = troshx_ZoneBody.create("to the Lower Legs",[1,3,1,1],["foot","shin_and_lower_leg","knee_and_nearby_areas",""]);
	this.zonesB[9] = troshx_ZoneBody.create("to the Upper Legs",[2,3,1],["knee_and_nearby_areas","thigh","hip"]);
	this.zonesB[10] = troshx_ZoneBody.create("to the Pelvis",[2,2,2],["hip","groin","lower_abdomen"]);
	this.zonesB[11] = troshx_ZoneBody.create("to the Belly",[6],["lower_abdomen"]);
	this.zonesB[12] = troshx_ZoneBody.create("to the Chest",[2,4],["upper_abdomen","chest"]);
	this.zonesB[13] = troshx_ZoneBody.create("to the Head",[1,3,2],["neck",["face","face","face","lower_head","lower_head"],"upper_head"]);
	this.zonesB[14] = troshx_ZoneBody.create("to the Arm",[1,2,1,2],["hand","forearm","elbow","upper_arm_and_shoulder"]);
	this.partsBludgeon.lower_abdomen = this.partsBludgeon.abdomen;
	this.partsBludgeon.arms = this.partsBludgeon.upper_arm_and_shoulder;
	this.partsBludgeon.shoulder = this.partsBludgeon.upper_arm_and_shoulder;
	this.partsCut.lower_abdomen = this.partsCut.abdomen;
	this.partsCut.upper_abdomen = this.partsCut.abdomen;
	this.partsCut.arms = this.partsCut.upper_arm_and_shoulder;
	this.centerOfMass = troshx_tros_HumanoidBody.CENTER_OF_MASS;
	this.centerOfMassT = troshx_tros_HumanoidBody.CENTER_OF_MASS_T;
};
troshx_tros_HumanoidBody.getInstance = function() {
	if(troshx_tros_HumanoidBody.INSTANCE != null) return troshx_tros_HumanoidBody.INSTANCE; else return troshx_tros_HumanoidBody.INSTANCE = new troshx_tros_HumanoidBody();
};
troshx_tros_HumanoidBody.__super__ = troshx_BodyChar;
troshx_tros_HumanoidBody.prototype = $extend(troshx_BodyChar.prototype,{
});
var __map_reserved = {}
troshx_BodyChar.D_DESTROY_PART = 1;
troshx_BodyChar.D_DEATH = 2;
troshx_BodyChar.WOUND_TYPE_CUT = 1;
troshx_BodyChar.WOUND_TYPE_PIERCE = 2;
troshx_BodyChar.WOUND_TYPE_BLUNT_TRAUMA = 4;
troshx_BodyChar.WOUND_D_DESTROY = 1;
troshx_BodyChar.WOUND_D_DEATH = 2;
troshx_tros_HumanoidBody.ZONE_I = 1;
troshx_tros_HumanoidBody.ZONE_II = 2;
troshx_tros_HumanoidBody.ZONE_III = 3;
troshx_tros_HumanoidBody.ZONE_IV = 4;
troshx_tros_HumanoidBody.ZONE_V = 5;
troshx_tros_HumanoidBody.ZONE_VI = 6;
troshx_tros_HumanoidBody.ZONE_VII = 7;
troshx_tros_HumanoidBody.ZONE_VIII = 8;
troshx_tros_HumanoidBody.ZONE_IX = 9;
troshx_tros_HumanoidBody.ZONE_X = 10;
troshx_tros_HumanoidBody.ZONE_XI = 11;
troshx_tros_HumanoidBody.ZONE_XII = 12;
troshx_tros_HumanoidBody.ZONE_XIII = 13;
troshx_tros_HumanoidBody.ZONE_XIV = 14;
troshx_tros_HumanoidBody.CENTER_OF_MASS = [3,2,5,6];
troshx_tros_HumanoidBody.CENTER_OF_MASS_T = [10,11,11,12];
Main.main();
})(typeof console != "undefined" ? console : {log:function(){}}, typeof window != "undefined" ? window : exports);
