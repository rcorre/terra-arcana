module gui.unitinfo;

import std.string;
import std.conv;
import dau.setup;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import model.all;

private enum {
  iconFmt = "icon_%s",
  effectFmt = "%s: %dx%d   Range: %d-%d",  // e.g. Damage: 3x2 Range: 1-2
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
      _hpBar.setVal(unit.hp);
      _apBar.setVal(unit.ap);
      _armorBar.setVal(unit.armor);
      _evadeBar.setVal(unit.evade);
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

  void showActionInfo(int actionNum) {
    if (_actionInfo !is null) {
      _actionInfo.active = false;
      _actionInfo = null;
    }
    if (actionNum == 1 || actionNum == 2) {
      auto offset = Vector2i(0, area.height);
      _actionInfo = addChild(new ActionInfo(offset, _unit.getAction(actionNum)));
    }
  }

  private:
  Unit _unit;
  PipBar _hpBar, _apBar, _evadeBar, _armorBar;
  ActionInfo _actionInfo;
  Icon _toxinIcon, _slowIcon, _flyingIcon;
  Vector2i _nextEffectOffset;
  Color _effectFlashColor;
  float _effectFlashTime;
}

private:
class ActionInfo : GUIElement {
  this(Vector2i topLeft, const UnitAction action) {
    super(getGUIData("actionInfo"), topLeft);
    addNameText(action.name);
    addEffectText(action);
    if (action.specials.length > 0) {
      addSpecialText(action.specials[0]);
    }
    //addApCostBar(action.apCost);
  }

  void addApCostBar(int amount) {
    auto apArea = data["apArea"].parseRect!int;
    addChild(new PipBar(getGUIData("apBar"), apArea, amount));
  }

  void addNameText(string name) {
    addChild(new TextBox(data.child["name"], name));
  }

  void addEffectText(const UnitAction action) {
    auto title = action.effect.to!string.capitalize;
    auto text = effectFmt.format(title, action.power, action.hits, action.minRange,
        action.maxRange);
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
