module gui.unitinfo;

import std.string, std.conv;
import dau.setup;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import model.all;

private enum {
  iconFmt = "icon_%s",
  effectFmt = "%s:%s  Range:%s [%s]",  // e.g. Damage:3x2 Range:1-2 [burst]
  apFormat = "%d AP"
}

/// bar that displays progress as discrete elements (pips)
class UnitInfoGUI : GUIElement {
  this(Unit unit, Vector2i offset) {
    // TODO: choose corner of unit based on screen positioning
    super(getGUIData("unitInfo"), offset);
    _nextEffectOffset = data["effectsOffset"].parseVector!int;
    if (unit !is null) {
      auto spriteOffset     = data["spriteOffset"].parseVector!int;
      auto unitIconData     = getGUIData(iconFmt.format(unit.key));
      addChild(new Icon(unitIconData, spriteOffset));
      addChild(new TextBox(data.child["nameText"]));

      // pip bars for hp, ap, armor, evade
      _hpBar = new PipBar(data.child["hpBar"], unit.maxHp);
      _apBar = new PipBar(data.child["apBar"], unit.maxAp);
      _armorBar = new PipBar(data.child["armorBar"]);
      _evadeBar = new PipBar(data.child["evadeBar"]);
      addChildren(_hpBar, _apBar, _armorBar, _evadeBar);

      //trait icons
      foreach(trait ; unit.traits) {
        addEffectIcon(trait.to!string);
      }
      if (unit.isToxic) {
        addEffectIcon("toxin", unit.toxin);
      }
      if (unit.isSlowed) {
        addEffectIcon("slow", unit.slow);
      }
      if (unit.isStunned) {
        addEffectIcon("stun", unit.stun);
      }
      _hpBar.setVal(unit.hp);
      _apBar.setVal(unit.ap);
      _armorBar.setVal(unit.armor);
      _evadeBar.setVal(unit.evade);
    }

    _unit = unit;
    _effectFlashColor = data["effectFlashColor"].parseColor;
    _effectFlashTime = data["effectFlashTime"].to!float;

    auto actionOffset = Vector2i(0, area.height);
    _actionInfo1 = addChild(new ActionInfo(actionOffset, _unit.getAction(1)));
    actionOffset += Vector2i(0, _actionInfo1.height);
    _actionInfo2 = addChild(new ActionInfo(actionOffset, _unit.getAction(2)));
  }

  @property auto unit() { return _unit; }

  @property totalSize() { return size + _actionInfo1.size + _actionInfo2.size; }

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
  PipBar _hpBar, _apBar, _evadeBar, _armorBar;
  Vector2i _nextEffectOffset;
  Color _effectFlashColor;
  float _effectFlashTime;
  ActionInfo _actionInfo1, _actionInfo2;
}

private:
class ActionInfo : GUIElement {
  this(Vector2i topLeft, const UnitAction action) {
    super(getGUIData("actionInfo"), topLeft);
    addChild(new TextBox(data.child["name"], action.name));
    addChild(new TextBox(data.child["apCost"], apFormat.format(action.apCost)));
    addEffectText(action);
    if (action.specials.length > 0) {
      addSpecialText(action.specials[0]);
    }
  }

  void addEffectText(const UnitAction action) {
    auto title = action.effect.to!string.capitalize;

    string effect = (action.hits > 1) ? 
      "%d".format(action.power) : 
      "%dx%d".format(action.power, action.hits);

    string range = (action.minRange == action.maxRange) ? 
      "%d".format(action.minRange) : 
      "%d-%d".format(action.minRange, action.maxRange);

    auto text = effectFmt.format(title, effect, range, action.target);

    addChild(new TextBox(data.child["effect"], text));
  }

  void addSpecialText(const UnitAction.Special special) {
    string text;
    final switch(special) with (UnitAction.Special) {
      case pierce:
        text = "Ignore Armor";
        break;
      case precise:
        text = "Ignore Evade";
        break;
      case blitz:
        text = "Ignore Counter";
        break;
    }

    addChild(new TextBox(data.child["special"], text));
  }
}
