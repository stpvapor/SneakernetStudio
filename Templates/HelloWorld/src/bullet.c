#include "bullet.h"

void bullet_init(Bullet *self, const char *png_path) {
    self->tex = LoadTexture(png_path);
    self->img = LoadImageFromTexture(self->tex);
    self->tex_width = self->tex.width;
    self->tex_height = self->tex.height;
    self->position = (Vector2){0, 0};
    self->velocity = (Vector2){0, 0};
}

void bullet_update(Bullet *self, float dt) {
    self->position.x += self->velocity.x * dt;
    self->position.y += self->velocity.y * dt;

    // Pixel-perfect wall bounce — only opaque pixels count
    for (int y = 0; y < self->tex_height; y++) {
        for (int x = 0; x < self->tex_width; x++) {
            Color p = GetImageColor(self->img, x, y);  // <-- no & here
            if (p.a > 0) {  // opaque pixel
                Vector2 world = {
                    self->position.x + x,
                    self->position.y + y
                };

                if (world.x <= 0 || world.x >= GetScreenWidth() - 1) {
                    self->velocity.x = -self->velocity.x;
                    return;  // one bounce per frame is enough
                }
                if (world.y <= 0 || world.y >= GetScreenHeight() - 1) {
                    self->velocity.y = -self->velocity.y;
                    return;
                }
            }
        }
    }
}

void bullet_draw(const Bullet *self) {
    DrawTexture(self->tex, (int)self->position.x, (int)self->position.y, WHITE);
}

void bullet_free(Bullet *self) {
    UnloadTexture(self->tex);
    UnloadImage(self->img);
}
