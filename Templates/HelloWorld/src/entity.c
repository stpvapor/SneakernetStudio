#include "entity.h"

void entity_update(Entity *self, float dt) {
    self->position.x += self->velocity.x * dt;
    self->position.y += self->velocity.y * dt;
}

void entity_draw(const Entity *self) {
    DrawCircleV(self->position, 20, RED);  // Red ball
}
