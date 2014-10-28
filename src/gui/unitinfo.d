module gui.unitinfo;

import std.string;
import std.conv;
import dau.setup;
import dau.geometry.all;
import dau.graphics.all;
import dau.gui.all;
import model.all;

private enum {
  spriteName       = "gui/unit_status",
  pipName          = "gui/pip",
  armorOffset      = Vector2i(18, 52),
  evadeOffset      = Vector2i(118, 51),
  hpArea           = Rect2i(37, 37, 63, 13),
  apArea           = Rect2i(37, 53, 63, 13),
  conditionOffset  = Vector2i(5, 73),
  actionBarOffset1 = Vector2i(137, 9),
  actionBarOffset2 = Vector2i(137, 57),
  actionBarSize    = Vector2i(200, 24),
  spriteOffset     = Vector2i(13, 0),
  nameOffset       = Vector2i(49, 12),
  iconSheetName    = "gui/icons"
}

/// bar that displays progress as discrete elements (pips)
class UnitInfoGUI : GUIElement {
  this(Unit unit, Vector2i offset) {
    // TODO: choose corner of unit based on screen positioning
    super(new Sprite(spriteName), offset);
    if (unit !is null) {
      _hpBar = new PipBar(hpArea, unit.maxHp, pipName, "hpPip");
      _apBar = new PipBar(apArea, unit.maxAp, pipName, "apPip");
      _armorText = new TextBox(unit.armor, _font, armorOffset, GUIElement.Anchor.center);
      _evadeText = new TextBox(unit.evade, _font, evadeOffset, GUIElement.Anchor.center);
      addChild(_hpBar);
      addChild(_apBar);
      addChild(_armorText);
      addChild(_evadeText);
      addChild(new ActionInfo(actionBarOffset1, unit.action1));
      addChild(new ActionInfo(actionBarOffset2, unit.action2));
      addChild(new Icon(new Animation(unit.key, "idle", Animation.Repeat.loop), spriteOffset));
      addChild(new TextBox(unit.name, _font, nameOffset));
      _hpBar.setVal(unit.hp);
      _apBar.setVal(unit.ap);
    }
    _unit = unit;
  }

  @property auto unit() { return _unit; }

  void animateHpChange(int from, int to, float duration) {
    _hpBar.transitionVal(from, to, duration);
  }

  void animateApChange(int from, int to, float duration) {
    _apBar.transitionVal(from, to, duration);
  }

  private:
  Unit _unit;
  PipBar _hpBar, _apBar;
  TextBox _armorText, _evadeText;
  ActionInfo _actionInfo1, _actionInfo2;
}

private:
class ActionInfo : GUIElement {
  private enum {
    actionIconOffset = Vector2i(2, 2),
    infoOffset = Vector2i(34, 2),
    apArea = Rect2i(37, 28, 51, 12),
    iconSeparation = 4
  }

  this(Vector2i topLeft, const UnitAction action) {
    super(Rect2i(topLeft, actionBarSize));
    auto actionName = action.name.toLower;
    addChild(new Icon(new Sprite(iconSheetName, actionName), actionIconOffset));
    addChild(new PipBar(apArea, action.apCost, pipName, "apPip"));
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
  onInit({ _font = Font("Mecha", 16); });
}
