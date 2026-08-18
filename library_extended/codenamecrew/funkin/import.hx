package codenamecrew.funkin.;

#if !macro
import codenamecrew.funkin.backend.system.Main;
import codenamecrew.funkin.backend.assets.Paths;
import codenamecrew.funkin.backend.MusicBeatState;
import codenamecrew.funkin.backend.MusicBeatSubstate;
import codenamecrew.funkin.backend.MusicBeatGroup;
import codenamecrew.funkin.backend.codenamecrew.funkin.Sprite;
import codenamecrew.funkin.backend.utils.*;
import codenamecrew.funkin.backend.utils.TranslationUtil as TU;
import codenamecrew.funkin.backend.system.Logs;
import codenamecrew.funkin.options.Options;
import codenamecrew.funkin.game.PlayState;
import codenamecrew.funkin.backend.scripting.EventManager;

import openfl.utils.Assets;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.util.FlxDestroyUtil;

import codenamecrew.funkin.backend.system.Flags;
import codenamecrew.funkin.Types;

import codenamecrew.funkin.menus.ui.Alphabet;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

using StringTools;
using codenamecrew.funkin.backend.utils.CoolUtil;
#end