#ifndef UTILS_H
#define UTILS_H

#include <raylib.h>

void DrawTextCenteredMulti(const char *text, int fontSize, Color color);

/* SCREEN SHAKE (camera) */
typedef struct {
    float intensity;
    float duration;
    float timer;
    Vector2 offset;
} ScreenShake;

void ScreenShakeTrigger(float intensity, float duration);
void ScreenShakeUpdate(float dt);
void ScreenShakeBegin(void);
void ScreenShakeEnd(void);

/* WINDOW SHAKE (OS window) */
typedef struct {
    float intensity;
    float duration;
    float timer;
    Vector2 offset;
    int base_x;
    int base_y;
} WindowShake;

void WindowShakeTrigger(float intensity, float duration);
void WindowShakeUpdate(float dt);
void WindowShakeApply(void);
void WindowShakeClear(void);

#endif
