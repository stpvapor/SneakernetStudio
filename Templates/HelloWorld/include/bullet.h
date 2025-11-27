#ifndef BULLET_H
#define BULLET_H

#include <raylib.h>

typedef struct Bullet {
    Vector2 position;
    Vector2 velocity;
    Texture2D tex;  // PNG sprite
    Image img;  // For alpha scan
    int tex_width, tex_height;
    int effective_width, effective_height;
    Vector2 *polygon;  // Outline points for collision
    int polygon_points;
} Bullet;

void bullet_init(Bullet *self, const char *png_path);
void bullet_update(Bullet *self, float dt);
void bullet_draw(const Bullet *self);
void bullet_free(Bullet *self);

#endif
