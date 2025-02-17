extern vec4 color1;
extern vec4 color2;
extern vec2 size;
extern vec2 center;
extern float rotation;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 Pos = screen_coords - center;

    float cosR = cos(rotation);
    float sinR = sin(rotation);
    vec2 rotated = vec2(cosR * Pos.x - sinR * Pos.y, sinR * Pos.x + sinR * Pos.y);

    float t = (rotated.x + (size.x * 0.5)) / size.x;
    vec4 gradient = mix(color1, color2, t);

    return gradient;
}
