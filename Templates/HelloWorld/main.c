#include <raylib.h>
#include "entity.h"
#include "bullet.h"
#include "include/utils.h"

int main(void) {
    const int screenWidth = 800;
    const int screenHeight = 450;
    const char *msg = "VAPORWARE SOFTWORKS\npresents\nSNEAKERNET STUDIO";

    InitWindow(screenWidth, screenHeight, "Sneakernet Studio - Hello World");
    SetTargetFPS(240);

    // Center window once
    int monitor = GetCurrentMonitor();
    SetWindowPosition(
        GetMonitorPosition(monitor).x + (GetMonitorWidth(monitor) - screenWidth) / 2,
        GetMonitorPosition(monitor).y + (GetMonitorHeight(monitor) - screenHeight) / 2
    );

    // Initialize window shake base (one-time)
    WindowShakeTrigger(0, 0);

    Entity player = {0};
    player.position = (Vector2){400, 225};
    player.velocity = (Vector2){100, 50};

    Bullet bullet = {0};
    bullet_init(&bullet, "assets/textures/VWSBrain.png");
    bullet.position = player.position;
    bullet.velocity = (Vector2){GetRandomValue(200, 250), GetRandomValue(10, 100)};

    Vector2 old_vel = bullet.velocity;

    while (!WindowShouldClose()) {
        float dt = GetFrameTime();

        old_vel = bullet.velocity;
        entity_update(&player, dt);
        bullet_update(&bullet, dt);

        // Dual shake on wall hit
        if ((old_vel.x > 0 && bullet.velocity.x < 0) ||
            (old_vel.x < 0 && bullet.velocity.x > 0) ||
            (old_vel.y > 0 && bullet.velocity.y < 0) ||
            (old_vel.y < 0 && bullet.velocity.y > 0)) {
            ScreenShakeTrigger(35.0f, 0.45f);
            WindowShakeTrigger(25.0f, 0.4f);
        }

        ScreenShakeUpdate(dt);
        WindowShakeUpdate(dt);

        BeginDrawing();
        ClearBackground(RAYWHITE);

        ScreenShakeBegin();
        WindowShakeApply();

        entity_draw(&player);
        bullet_draw(&bullet);

        DrawTextCenteredMulti(msg, 30, LIGHTGRAY);
        DrawFPS(10, 10);

        ScreenShakeEnd();

        EndDrawing();
    }

    bullet_free(&bullet);
    WindowShakeClear();
    CloseWindow();
    return 0;
}
