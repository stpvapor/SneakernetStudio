#include "utils.h"
#include <raylib.h>   // <-- THIS WAS MISSING
#include <math.h>

static ScreenShake screen_shake = {0};
static WindowShake window_shake = {0};

/* TEXT — multi-line centered */
void DrawTextCenteredMulti(const char *text, int fontSize, Color color) {
    int count = 0;
    const char *lines[64];
    lines[count++] = text;
    for (int i = 0; text[i]; i++) {
        if (text[i] == '\n') lines[count++] = text + i + 1;
    }

    int maxWidth = 0;
    for (int i = 0; i < count; i++) {
        int w = MeasureText(lines[i], fontSize);
        if (w > maxWidth) maxWidth = w;
    }

    int totalHeight = count * fontSize;
    int startX = (GetScreenWidth() - maxWidth) / 2;
    int startY = (GetScreenHeight() - totalHeight) / 2;

    for (int i = 0; i < count; i++) {
        int w = MeasureText(lines[i], fontSize);
        int x = startX + (maxWidth - w) / 2;
        DrawText(lines[i], x, startY + i * fontSize, fontSize, color);
    }
}

/* MATH */
float LerpF(float a, float b, float t) { return a + (b - a) * t; }

Vector2 LerpVec2(Vector2 a, Vector2 b, float t) {
    return (Vector2){ LerpF(a.x, b.x, t), LerpF(a.y, b.y, t) };
}

float EaseOutElastic(float t) {
    const float c4 = (2.0f * 3.14159265359f) / 3.0f;
    return t == 0 ? 0 : t == 1 ? 1 : powf(2, -10 * t) * sinf((t * 10 - 0.75f) * c4) + 1;
}

float RandomFloat(float min, float max) {
    return min + ((float)GetRandomValue(0, 10000) / 10000.0f) * (max - min);
}

/* SCREEN SHAKE */
void ScreenShakeTrigger(float intensity, float duration) {
    screen_shake.intensity = intensity;
    screen_shake.duration = duration;
    screen_shake.timer = duration;
}

void ScreenShakeUpdate(float dt) {
    if (screen_shake.timer > 0) {
        screen_shake.timer -= dt;
        float t = screen_shake.timer / screen_shake.duration;
        float strength = screen_shake.intensity * EaseOutElastic(1.0f - t);
        screen_shake.offset.x = RandomFloat(-strength, strength);
        screen_shake.offset.y = RandomFloat(-strength, strength);
    } else {
        screen_shake.offset = (Vector2){0, 0};
    }
}

void ScreenShakeBegin(void) {
    BeginMode2D((Camera2D){
        .offset = screen_shake.offset,
        .target = (Vector2){0, 0},
        .rotation = 0.0f,
        .zoom = 1.0f
    });
}

void ScreenShakeEnd(void) {
    EndMode2D();
}

/* WINDOW SHAKE */
void WindowShakeTrigger(float intensity, float duration) {
    window_shake.intensity = intensity;
    window_shake.duration = duration;
    window_shake.timer = duration;
    window_shake.base_x = GetMonitorPosition(0).x + (GetMonitorWidth(0) - GetScreenWidth()) / 2;
    window_shake.base_y = GetMonitorPosition(0).y + (GetMonitorHeight(0) - GetScreenHeight()) / 2;
}

void WindowShakeUpdate(float dt) {
    if (window_shake.timer > 0) {
        window_shake.timer -= dt;
        float t = window_shake.timer / window_shake.duration;
        float strength = window_shake.intensity * (1.0f - t) * (1.0f - t);
        window_shake.offset.x = RandomFloat(-strength, strength);
        window_shake.offset.y = RandomFloat(-strength, strength);
    } else {
        window_shake.offset = (Vector2){0, 0};
    }
}

void WindowShakeApply(void) {
    SetWindowPosition(window_shake.base_x + (int)window_shake.offset.x,
                      window_shake.base_y + (int)window_shake.offset.y);
}

void WindowShakeClear(void) {
    window_shake.timer = 0;
    window_shake.offset = (Vector2){0, 0};
    SetWindowPosition(window_shake.base_x, window_shake.base_y);
}
