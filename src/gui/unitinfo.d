module gui.unitinfo;

import std.string;
import std.conv;
import dau.setup;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import model.all;

private enum iconFmt = "icon_%s";

/// bar that displays progress as discrete elements (pips)
class UnitInfoGUI : GUIElement {
  this(Unit unit, Vector2i offset) {
    // TODO: choose corner of unit based on screen positioning
    super(getGUIData("unitInfo"), offset);
    _nextEffectOffset = data["effectsOffset"].parseVector!int;
    if (unit !is null) {
      auto hpArea = data["hpArea"].parseRect!int;
      auto apArea = data["apArea"].parseRect!int;
      auto armorOffset = data["armorOffset"].parseVector!int;
      auto evadeOffset = data["evadeOffset"].parseVector!int;
      auto actionBarOffset1 = data["actionBarOffset1"].parseVector!int;
      auto actionBarOffset2 = data["actionBarOffset2"].parseVector!int;
      auto nameOffset = data["nameOffset"].parseVector!int;
      auto actionBarSize = data["actionBarSize"].parseVector!int;
      _hpBar = new PipBar(data.child["hpBar"], hpArea, unit.maxHp);
      _apBar = new PipBar(data.child["apBar"], apArea, unit.maxAp);
      _armorText = new TextBox(data.child["text"], unit.armor, armorOffset, GUIElement.Anchor.center);
      _evadeText = new TextBox(data.child["text"], unit.evade, evadeOffset, GUIElement.Anchor.center);
      addChild(_hpBar);
      addChild(_apBar);
      addChild(_armorText);
      addChild(_evadeText);
      addChild(new ActionInfo(actionBarOffset1, actionBarSize, unit.action1));
      addChild(new ActionInfo(actionBarOffset2, actionBarSize, unit.action2));
      //addChild(new Icon(new Animation(unit.key, "idle", Animation.Repeat.loop), spriteOffset));
      addChild(new TextBox(data.child["text"], unit.name, nameOffset));
      foreach(trait ; unit.traits) {
        addEffectIcon(trait.to!string);
      }
      if (unit.isToxic) {
        addEffectIcon("toxin", unit.toxin);
      }
      if (unit.isSlowed) {
        addEffectIcon("slow", unit.slow);
      }
      _hpBar.setVal(unit.hp);
      _apBar.setVal(unit.ap);
    }
    _unit = unit;
    _effectFlashColor = data["effectFlashColor"].parseColor;
    _effectFlashTime = data["effectFlashTime"].to!float;
  }

  @property auto unit() { return _unit; }

  void animateHpChange(int from, int to, float duration) {
    _hpBar.transitionVal(from, to, duration);
  }

  void animateApChange(int from, int to, float duration) {
    _apBar.transitionVal(from, to, duration);
  }

  void animateEffect(string name, int val) {
    auto icon = addEffectIcon(name, val);
    icon.flash(_effectFlashTime, _effectFlashColor);
  }

  auto addEffectIcon(string iconName) {
    auto iconData = getGUIData(iconFmt.format(iconName));
    auto icon = addChild(new Icon(iconData, _nextEffectOffset));
    _nextEffectOffset.x += icon.width;
    return icon;
  }

  auto addEffectIcon(string iconName, int val) {
    auto iconData = getGUIData(iconFmt.format(iconName));
    auto textData = data.child["text"];
    auto icon = addChild(new Icon(iconData, textData, _nextEffectOffset, val));
    _nextEffectOffset.x += icon.width;
    return icon;
  }

  private:
  Unit _unit;
  PipBar _hpBar, _apBar;
  TextBox _armorText, _evadeText;
  ActionInfo _actionInfo1, _actionInfo2;
  Icon _toxinIcon, _slowIcon, _flyingIcon;
  Vector2i _nextEffectOffset;
  Color _effectFlashColor;
  float _effectFlashTime;
}

private:
class ActionInfo : GUIElement {
  this(Vector2i topLeft, Vector2i size, const UnitAction action) {
    super(getGUIData("actionInfo"), Rect2i(topLeft, size));
    addActionIcon(action.name);
    addApCostBar(action.apCost);
    Vector2i offset = data["infoOffset"].parseVector!int;
    _iconSeparation = data["iconSeparation"].to!int;
    addEffectIcon(action, offset);
    addRangeIcon(action, offset);
    foreach(special ; action.specials) {
      addSpecialIcon(special, offset);
    }
  }

  void addApCostBar(int amount) {
    auto apArea = data["apArea"].parseRect!int;
    addChild(new PipBar(data.child["apBar"], apArea, amount));
  }

  void addActionIcon(string name) {
    auto actionName = name.toLower;
    auto iconData = new GUIData;
    iconData["texture"] = data["iconSheetName"];
    iconData["sprite"] = actionName;
    auto offset = data["actionIconOffset"].parseVector!int;
    addChild(new Icon(iconData, offset));
  }

  void addEffectIcon(const UnitAction action, ref Vector2i offset) {
    auto iconData = getGUIData(iconFmt.format(action.effect));
    auto textData = data.child["text"];
    string text;
    if (action.hits > 1) {
      text = "%dx%d".format(action.power, action.hits);
    }
    else {
      text = "%d".format(action.power);
    }
    addInfo(new Icon(iconData, textData, offset, text), offset);
  }

  void addRangeIcon(const UnitAction action, ref Vector2i offset) {
    if (action.maxRange > 0) {
      auto iconData = getGUIData("icon_range");
      auto textData = data.child["text"];
      auto text = "%d-%d".format(action.minRange, action.maxRange);
      addInfo(new Icon(iconData, textData, offset, text), offset);
    }
  }

  void addSpecialIcon(UnitAction.Special special, ref Vector2i offset) {
    auto iconData = getGUIData(iconFmt.format(special.to!string));
    addInfo(new Icon(iconData, offset), offset);
  }

  void addInfo(Icon icon, ref Vector2i offset) {
    addChild(icon);
    offset.x += icon.area.width + _iconSeparation;
  }

  int _iconSeparation;
}
