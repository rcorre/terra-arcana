module dau.graphics.primitive;

import dau.allegro;
import dau.graphics.color;
import dau.geometry.all;

/// draw a point
void draw(T)(Vector2!T point, float radius = 1, ALLEGRO_COLOR color = Color.white) {
  al_draw_filled_circle(point.x, point.y, radius, color);
}

/// draw a path based on a series of points
void draw(T)(Vector2!T[] points, float thickness = 1, ALLEGRO_COLOR color = Color.white) {
  Vector2i start = points[0];
  foreach(idx, end ; points[1 .. $]) {
    al_draw_line(start.x, start.y, end.x, end.y, color, thickness);
    start = end;
  }
}

/// draw a rectangle outline
void draw(T)(Rect2!T rect, float thickness = 1, ALLEGRO_COLOR color = Color.white, float rx = 0, float ry = 0) {
    al_draw_rounded_rectangle(rect.x, rect.y, rect.right, rect.bottom, rx, ry, color, thickness);
}

/// draw a filled rectangle
void drawFilled(T)(Rect2!T rect, ALLEGRO_COLOR color = Color.white, float rx = 0, float ry = 0) {
  al_draw_filled_rounded_rectangle(rect.x, rect.y, rect.right, rect.bottom, rx, ry, color);
}
