package troshx.sos.vue.widgets;
import haxevx.vuex.core.NoneT;
import haxevx.vuex.core.VComponent;
import js.html.InputElement;
import troshx.sos.core.Skill;
import troshx.util.LibUtil;

/**
 * ...
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
		var b:Bool = !LibUtil.field(permaHash, selectedSubject);
		return a && b;
	}

	
	function onSelectSubjectChange():Void {
		if (editMode ) {
			
			editFieldText = selectedSubject;
			
		}
		//touchedEditField = false;
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
		_vEmit("deleteSubject", selectedSubject);
	}
	
	function onAddSkillClick():Void {
		_vEmit("addSkill", selectedSubject, selectedSkill);
	}
	
	@:computed function get_comboName():String {
		return Skill.specialisationName(selectedSkill, selectedSubject);
	}
	
	function onAddBtnClick():Void {
		// perform adding of subject
	}
	
	

	function onRenameBtnClick():Void {
		if (selectedSubject != editFieldText) {
			
			_vEmit("renameSubject", selectedSubject, editFieldText);
			editFieldText = "";
		}
	}
	
	@:computed function get_renameButtonInvalid():Bool {
	
		return editFieldText == "";
	
	}
	
	@:computed function get_addButtonInvalid():Bool {
	
		return skillSubjects.indexOf(editFieldText) >= 0 || editFieldText == "";
	}
	
	@:computed function get_isAddSkillDisabled():Bool {
		var ss = selectedSubject;
		var skv = skillValues;
		return selectedSkill == "" || ss == "" || LibUtil.field(skv, Skill.specialisationName(selectedSkill, ss))>=0;
	}

	// TODO: Delete button needs a subject hash to check against, in case a partiuclar lone subject is already being used

	
	override function Template():String {
		return '<div class="skill-subjects">
			<div class="columner col-skills">
				<h4>Skill: <span style="font-weight:normal;white-space:nowrap">{{comboName}}</span></h4>
				<select size="5" v-model="selectedSkill">
					<option v-for="(li, i) in skillList" :key="li" :value="li">{{li}}</option>
				</select>
				<div><button :disabled="isAddSkillDisabled" v-on:click="onAddSkillClick">{{skillValues[comboName]>=0 ? "Already Exists" : "^Add Skill"}}</button></div>
			</div>
			<div class="columner col-subject">
				<h4>Specialisations:</h4>
				<select size="6" v-model="selectedSubject" v-on:change="onSelectSubjectChange">
					<option v-for="(li, i) in skillSubjects" :key="li" :value="li">{{li}}</option>
				</select>
				
			</div>
			<div class="columner col-add-subject">
				<div>
					<h4>Specialisation</h4>
					<label><input type="radio" name="edit-mode" :checked="!editMode" v-on:click="editMode = false"></input>New</label>
					<label><input type="radio" name="edit-mode" :checked="editMode"  v-on:click="editMode = true"></input>Edit</label>
					<button class="del" v-show="withinEditableScope && editMode" v-on:click="deleteBtnClick">Del</button>
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
	@:prop({required:true}) var permaHash:Dynamic<Bool>;
	@:prop({required:true}) var skillList:Array<String>;
	
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