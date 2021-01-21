TrosHAXE Project Repository for Song of Swords
-----------------------------------------------

For Haxe compiling to Javascript, consider HaxeDevelop or VIsual Studio code. More info here:
	
As of now, you need an earlier Haxe 3 SDK (not HAxe 4) for this project. Get the latest Haxe 3 here: https://haxe.org/download/version/3.4.7/

After Haxe 3 SDK installed, ensure you have the following libraries installed under `haxelib`.


```
haxelib install haxevx
haxelib install msignal
````


## Song of Swords Doll Viewer/Minigame


Currently, developing project current main: `src/troshx/sos/vue/tests/TestUI.hx` for DollView UI and test hotseat/hotphone bout combat game. Roadmap to include multiplayer as well.

View/test under `bin/indext.html` locally.

### Important Note:
	
You need Haxe compiler to compile main Hx class.
Also, you need a SCSS compiler  (or `sass` available on command line together HaxeDevelop to save SCSS files ) to export out to CSS files in same folder for viewing at `bin/scss/pages/dollview.scss`. Ensure you compile SCSS to ensure you have the latest css stylesheet!