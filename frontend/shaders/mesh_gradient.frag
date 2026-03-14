#include <flutter/runtime_effect.glsl>

uniform vec2 u_res;

// 6 control points: positions (x,y in 0..1 range)
uniform vec2 u_p0;
uniform vec2 u_p1;
uniform vec2 u_p2;
uniform vec2 u_p3;
uniform vec2 u_p4;
uniform vec2 u_p5;

// 6 control point colours (RGB 0..1)
uniform vec3 u_c0;
uniform vec3 u_c1;
uniform vec3 u_c2;
uniform vec3 u_c3;
uniform vec3 u_c4;
uniform vec3 u_c5;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / u_res;
    float aspect = u_res.x / u_res.y;
    vec2 st = vec2(uv.x * aspect, uv.y);

    vec2 pts[6];
    pts[0] = vec2(u_p0.x * aspect, u_p0.y);
    pts[1] = vec2(u_p1.x * aspect, u_p1.y);
    pts[2] = vec2(u_p2.x * aspect, u_p2.y);
    pts[3] = vec2(u_p3.x * aspect, u_p3.y);
    pts[4] = vec2(u_p4.x * aspect, u_p4.y);
    pts[5] = vec2(u_p5.x * aspect, u_p5.y);

    vec3 cols[6];
    cols[0] = u_c0;
    cols[1] = u_c1;
    cols[2] = u_c2;
    cols[3] = u_c3;
    cols[4] = u_c4;
    cols[5] = u_c5;

    vec3 colour = vec3(0.0);
    float totalW = 0.0;

    for (int i = 0; i < 6; i++) {
        float d = distance(st, pts[i]);
        float w = 1.0 / pow(d + 0.0001, 3.0);
        colour += cols[i] * w;
        totalW += w;
    }

    colour /= totalW;
    fragColor = vec4(colour, 1.0);
}
