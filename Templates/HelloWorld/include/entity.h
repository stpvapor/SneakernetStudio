#ifndef ENTITY_H
#define ENTITY_H

#include <raylib.h>

typedef struct Entity {
    Vector2 position;
    Vector2 velocity;
} Entity;

void entity_update(Entity *self, float dt);
void entity_draw(const Entity *self);  // Red ball

#endif
