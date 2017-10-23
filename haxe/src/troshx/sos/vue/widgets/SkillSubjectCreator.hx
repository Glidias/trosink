package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import haxevx.vuex.native.Vue;
import js.html.InputElement;
import js.html.SelectElement;
import troshx.sos.core.Skill;
import troshx.util.LibUtil;

/**
 * Widget to handle custom skill creation
 * @author Glidias
 */
class SkillSubjectCreator extends VComponent<SkillSubjectCreatorData, SkillSubjectCreatorProps>
{
	
	public static inline var NAME:String = "SkillSubjectCreator";

	public function new() 
	{
		super();
	}
	
	override function Data():SkillSubjectCreatorData {
		return new SkillSubjectCreatorData();
	}
	
	
	@:computed function get_withinEditableScope():Bool {
		var a = selectedSubject != "";
		var b:Bool = permaHash != null ? !LibUtil.field(permaHash, selectedSubject) : true;
		return a && b;
	}

	
	function onSelectSubjectChange():Void {
		if (editMode ) {
			
			editFieldText = selectedSubject;
			
		}
		//touchedEditField = false;
		
		notifyExistsIfNeeded();
	}
	
	inline function notifyExistsIfNeeded():Void {
		if (selectedSubject == "" || selectedSkill == "") {
			return;
		}
		if (LibUtil.field(skillValues, comboName) >= 0) {
			_vEmit("exists", selectedSkill, selectedSubject);
		}
	}
	
	function onSelectSkillChange():Void {
		notifyExistsIfNeeded();
	}
	
	function onTouchEditField():Void {
		//touchedEditField = true;
	}
	
	@:watch function watch_editMode(editing:Bool):Void {
		if (!editing) {
			editFieldText = "";
		}
		else {  //
			editFieldText = selectedSubject;
		}
		//touchedEditField = false;
	}
	
	function deleteBtnClick():Void {
		//_vEmit("deleteSubject", selectedSubject);
		
		var txt  = selectedSubject;
		editFieldText = "";
		selectedSubject = "";
		var i = skillSubjects.indexOf(txt);
		if (i >= 0) {
			skillSubjects.splice(i, 1);
		}
	}
	
	function onRenameBtnClick():Void {
		
		if (selectedSubject != editFieldText) {
			var txt = editFieldText;
			//_vEmit("renameSubject", selectedSubject, txt);
			editFieldText = "";
			var i:Int = skillSubjects.indexOf(selectedSubject);
			if ( i >= 0) {
				Vue.set( skillSubjects, i, txt);
				selectedSubject = txt;
				var htmlSelect:SelectElement  = _vRefs.selectSubject;
				htmlSelect.focus();	
			}
		}
	}
	
	function onAddSkillClick():Void {
		_vEmit("addSkill", selectedSkill, selectedSubject);
	}
	
	@:computed function get_comboName():String {
		return Skill.specialisationName(selectedSkill, selectedSubject);
	}
	
	function onAddBtnClick():Void {

		var txt = this.editFieldText;
		this.skillSubjects.push(txt);
		this.editFieldText = "";
		selectedSubject = txt;
		var htmlSelect:SelectElement  = _vRefs.selectSubject;
		htmlSelect.focus();
	}


	
	@:computed function get_renameButtonInvalid():Bool {
		return isDeleteSubjectDisabled;
		//return editFieldText == selectedSubject || skillSubjects.indexOf(editFieldText) >= 0;
	
	}
	@:computed function get_isDeleteSubjectDisabled():Bool {
		var ins = LibUtil.field(this.skillSubjectHash, selectedSubject);
		return ins != null && ins.length > 0;
	}

	
	@:computed function get_addButtonInvalid():Bool {
	
		return skillSubjects.indexOf(editFieldText) >= 0 || editFieldText == "";
	}
	
	@:computed function get_isAddSkillDisabled():Bool {
		var ss = selectedSubject;
		var skv = skillValues;
		return selectedSkill == "" || ss == "" || LibUtil.field(skv, Skill.specialisationName(selectedSkill, ss))>=0;
	}


	
	override function Template():String {
		return '<div class="skill-subjects">
			<div class="columner col-skills">
				<h4>Skill: <span style="font-weight:normal;white-space:nowrap">{{comboName}}</span></h4>
				<select size="5" ref="selectSkill" v-model="selectedSkill" v-on:change="onSelectSkillChange">
					<option v-for="(li, i) in skillList" :key="li" :value="li">{{li}}</option>
				</select>
				<div><button :disabled="isAddSkillDisabled" v-on:click="onAddSkillClick">{{skillValues[comboName]>=0 ? "Already Exists" : "^Add Skill Entry"}}</button></div>
			</div>
			<div class="columner col-subject">
				<h4>Specialisations:</h4>
				<select size="6" ref="selectSubject" v-model="selectedSubject" v-on:change="onSelectSubjectChange">
					<option v-for="(li, i) in skillSubjects" :key="li" :value="li">{{li}}</option>
				</select>
				
			</div>
			<div class="columner col-add-subject">
				<div>
					<h4>Specialisation</h4>
					<label><input type="radio" name="edit-mode" :checked="!editMode" v-on:click="editMode = false"></input>New</label>
					<label><input type="radio" name="edit-mode" :checked="editMode"  v-on:click="editMode = true"></input>Edit</label>
					<button class="del" :disabled="isDeleteSubjectDisabled" v-show="withinEditableScope && editMode" v-on:click="deleteBtnClick">Del</button>
				</div>
				<div><input type="text" v-on:input="onTouchEditField" v-model="editFieldText" :disabled="editMode && !withinEditableScope"></input></div>
				<div><button v-show="editMode && withinEditableScope" v-on:click="onRenameBtnClick" :disabled="renameButtonInvalid">&lt;&lt;Rename</button><button v-show="!editMode" v-on:click="onAddBtnClick" :disabled="addButtonInvalid">&lt;&lt;Add</button></div>
			</div>
		</div>';
	}
	
}

typedef SkillSubjectCreatorProps = {
	@:prop({required:true}) var skillSubjects:Array<String>;
	@:prop({required:true}) var skillValues:Dynamic<Int>;  // for internal validation of existing skill values
	@:prop({required:false}) @:optional var permaHash:Dynamic<Bool>;
	@:prop({required:true}) var skillList:Array<String>;
	@:prop({required:true}) var skillSubjectHash:Dynamic<Array<String>>;
	
}

class SkillSubjectCreatorData {
	public var editMode:Bool = false;
	public var selectedSubject:String = "";
	public var editFieldText:String = "";
	public var selectedSkill:String = "";
	//public var touchedEditField:Bool = false;
	
	public function new() {
		
	}
}