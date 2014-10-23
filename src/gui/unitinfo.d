module gui.unitinfo;

import std.string;
import std.conv;
import dau.setup;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import model.unit;

private enum {
  spriteName       = "gui/unit_status",
  pipName          = "gui/pip",
  armorOffset      = Vector2i(21, 53),
  evadeOffset      = Vector2i(180, 53),
  hpArea           = Rect2i(41, 38, 63, 13),
  apArea           = Rect2i(108, 38, 51, 13),
  statOffset       = Vector2i(41, 53),
  actionBarOffset1 = Vector2i(0, 77),
  actionBarOffset2 = Vector2i(0, 105),
  actionBarSize    = Vector2i(200, 24),
  iconSheetName    = "gui/icons"
}

/// bar that displays progress as discrete elements (pips)
class UnitInfoGUI : GUIElement {
  this(Unit unit) {
    // TODO: choose corner of unit based on screen positioning
    super(new Sprite(spriteName), unit.area.bottomRight);
    _hpBar = new PipBar(hpArea, unit.maxHp, pipName, "hpPip");
    _apBar = new PipBar(apArea, unit.maxAp, pipName, "apPip");
    _armorText = new TextBox(unit.baseArmor, _font, armorOffset, GUIElement.Anchor.center);
    _evadeText = new TextBox(unit.baseEvade, _font, evadeOffset, GUIElement.Anchor.center);
    addChild(_hpBar);
    addChild(_apBar);
    addChild(_armorText);
    addChild(_evadeText);
    addChild(new ActionInfo(actionBarOffset1, unit.action1));
    addChild(new ActionInfo(actionBarOffset2, unit.action2));
    _hpBar.setVal(unit.hp);
    _apBar.setVal(unit.ap);
  }

  private:
  PipBar _hpBar, _apBar;
  TextBox _armorText, _evadeText;
  ActionInfo _actionInfo1, _actionInfo2;
}

private:
class ActionInfo : GUIElement {
  private enum {
    actionIconOffset = Vector2i(2, 2),
    infoOffset = Vector2i(34, 2),
    iconSeparation = 4
  }

  this(Vector2i topLeft, const UnitAction action) {
    super(Rect2i(topLeft, actionBarSize));
    auto actionName = action.name.toLower;
    addChild(new Icon(new Sprite(iconSheetName, actionName), actionIconOffset));
    Vector2i offset = infoOffset;
    addEffectIcon(action, offset);
    addRangeIcon(action, offset);
    foreach(special ; action.specials) {
      addSpecialIcon(special, offset);
    }
  }

  void addEffectIcon(const UnitAction action, ref Vector2i offset) {
    auto sprite = new Sprite(iconSheetName, action.effect.to!string);
    string text;
    switch (action.target) with (UnitAction.Target) {
      case enemy:
      case ground:
        text = "%dx%d".format(action.power, action.hits);
        break;
      case ally:
      case self:
        text = "%d".format(action.power);
        break;
      default:
        text = "";
    }
    addInfo(new Icon(sprite, offset, text, _font), offset);
  }

  void addRangeIcon(const UnitAction action, ref Vector2i offset) {
    switch (action.target) with (UnitAction.Target) {
      case enemy:
      case ground:
      case ally:
        auto sprite = new Sprite(iconSheetName, "range");
        auto text = "%d-%d".format(action.minRange, action.maxRange);
        addInfo(new Icon(sprite, offset, text, _font), offset);
        break;
      default:
    }
  }

  void addSpecialIcon(UnitAction.Special special, ref Vector2i offset) {
    auto sprite = new Sprite(iconSheetName, special.to!string);
    addInfo(new Icon(sprite, offset), offset);
  }

  void addInfo(Icon icon, ref Vector2i offset) {
    addChild(icon);
    offset.x += icon.area.width + iconSeparation;
  }
}

Font _font;

static this() {
  onInit({ _font = Font("Mecha", 20); });
}
