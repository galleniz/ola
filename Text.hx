package utils;

import flixel.group.FlxSpriteContainer.FlxTypedSpriteContainer;

class Text extends FlxTypedSpriteContainer<Key>
{
    public var font(default, set):String;
    public var text(default, set):String;
    public var curText:String;
    public var spacingWidth:Int = 1;
    public var spacingHeight:Int = 1;
    public var curTextIndex:Int;
    public var textPerRow:Int = 0;
    public var maxWidth:Int = 0;
    private var _snd:FlxSound;
    public var sound(default, set):String;
    
    
    function set_sound(s:String):String {
        var path = Paths.sound('dialogue/$s');
        if (!Paths.exists(path)){
            path = Paths.sound('dialogue/default');
            s = 'default';
        }
        if (this.sound == s)
            return this.sound;

        if (_snd == null) {
            _snd = FlxG.sound.load(path);
        } else {
            _snd.loadEmbedded(path);
        }
        _snd.autoDestroy = false;
        return this.sound = s;
    }
    override function destroy() {
        super.destroy();
        if (_snd != null) {
            _snd.destroy();
            _snd = null;
        }
    }
    var isTyping:Bool = false;
    public function new(text:String, font:String = 'determination', spacingWidth:Int = 1, spacingHeight:Int = 1) {
        super();
        this.font = font;
        this.text = text;
        sound = 'default';
        this.spacingWidth = spacingWidth;
        this.spacingHeight = spacingHeight;
    }
    function set_font(f:String):String {
        if (this.font == f)
            return this.font;
        for (i in members)
            i.font = f;
        return this.font = f;
    }
    public var size:Int = 16;
    function set_text(t:String):String {
        if (this.text == t)
            return this.text;
        var row = 0;
        var curTextIndex = 0;
        var startedByApostrophe = false;
        while (members.length > 0) {
            var key:Key = members.pop();
            remove(key, true);
            key.destroy();
        }
        var firstLetter:Key = null;
        for (i in 0...t.length) {
            var text = t.charAt(i);
          
            if (text == ' ' ) {
                curTextIndex++;
                continue;
            }
            if (text == '\n') {
                row++;
                curTextIndex = 0;

                if (startedByApostrophe) {
                    curTextIndex+= 2; // asume que es un espacio, osea 1 es el *, y el 2 es el espacio, se supone que es un espacio
                    // ojala los writers lo hagan bien
                }
                continue;
            }
            
            var key:Key = new Key(font, t.charAt(i));
          if (text != '*' && text != ' ') {
                if (firstLetter == null) {
                    firstLetter = key;
                }
            }
            if (text == '*') {
                curTextIndex = 0;
                startedByApostrophe = true;
                
            }
        
            key.setPosition(0, 0);
            key.alpha = 1;
            add(key);
            key.x = curTextIndex * size * spacingWidth;
            key.y = row * (firstLetter ?? key).frameHeight * spacingHeight;

            if (key.x > maxWidth && maxWidth > 0) {
                row++;
                if (startedByApostrophe) {
                    curTextIndex+= 2; // asume que es un espacio, osea 1 es el *, y el 2 es el espacio, se supone que es un espacio
                    // ojala los writers lo hagan bien
                }
                curTextIndex = 0;
                key.x = curTextIndex * key.width * spacingWidth;
                key.y = row * key.height * spacingHeight;
            }
            
            key.visible = !isTyping;
            
            key.play(text);
            curTextIndex++;

        }
        return this.text =curText= t;
    }

    public function typingText(text:String, instant:Bool = false) {
        isTyping = true;
        this.text = text;
        if (instant) {
            startTyping();
        }
    }
    public var delay:Float = 1/15;
    public var isBusy:Bool = false;
    private var _typingText:Bool = false;
    public function startTyping(delay:Float = 1/15, sound:String = 'default') {
        if (!isTyping)
            return;
        curTextIndex = 0;
        _typingText = true;
        isBusy = true;
        this.delay = delay;
       
        for (i in members)
            i.visible = false; // porsi las dudas
        _snd.pause();
        delayTime=0;



    }
    var delayTime:Float = 0;
    override function update(elapsed:Float) {
        super.update(elapsed);
        FlxG.watch.addQuick('timer', delayTime);
        FlxG.watch.addQuick('delay', delay);
        if (_typingText) {

            delayTime += elapsed;
        
            var delayOffset = 1;
            if (text.charAt(curTextIndex - 1) == '*') {
                delayOffset = 5;
            }
            if (text.charAt(curTextIndex) == '\n') {
                delayOffset = 5;
            }
            if (text.charAt(curTextIndex) == ' ') {
                delayOffset = 2;
            }
            if (delayTime > delay * delayOffset ) {
                delayTime = 0;
                _snd.play(true);

                if (curTextIndex >=members.length) {
                    _typingText = false;
                    isBusy = false;
                    return;
                } else {
                    if (members[curTextIndex] != null) {
                        members[curTextIndex].visible = true;
                    }
                }
                curTextIndex++;

            }
        }
    }

}
private class Key extends FlxSprite {
    public var font(default, set):String;
    public var animOffset:Map<String, Int>;
    
    function set_font(font:String):String {
        if (this.font == font)
            return this.font;
        var path = 'fnt_'+ loadData(font);
        animOffset = new Map();
        if (font == 'determination' ) {
            animOffset.set('q', -5);
        }

        frames = Paths.packetFont(path + '/$path');
        return this.font = font;
    }
    public function new(font:String = 'determination', text:String = '*') {
        super();
        this.font = font;
        play(text);
    }
    var _curAnim : String;
    public function play(text:String) {
        if (_curAnim == text)
            return;
        _curAnim = text;
        var a = Std.string(text.charCodeAt(0)) ;
        animation.addByPrefix('animation', a, 0, false); // like if its "SPACE" it will be 32
        animation.play('animation');
        // updateHitbox();
        // if (animOffset.exists(_curAnim)) {
        //     offset.y+= animOffset.get(_curAnim);
        // }
        
    }
    override function update(elapsed:Float) {
        super.update(elapsed);
      
    }
    function loadData(font:String = 'determination') {
        return switch font {
            default:
                'main';
        }
        
    }

}