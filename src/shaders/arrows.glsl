#if defined VERTEX_SHADER
in vec3 tip;
in vec3 tail;
in vec3 color;

out vec3 vTail;
out vec3 vTip;
out vec3 vColor;

uniform mat4 projection;
uniform mat4 modelview;

void main() {
    vTip = (modelview * vec4(tip, 1.0)).xyz;
    vTail = (modelview * vec4(tail, 1.0)).xyz;
    vColor = color;
}

#elif defined GEOMETRY_SHADER

layout (points) in;
layout (triangle_strip, max_vertices=7) out;

in vec3 vTip[];
in vec3 vTail[];
in vec3 vColor[];
out vec3 gColor;

uniform mat4 projection;
uniform mat4 modelview;

void main() {
    vec3 tail = vTail[0];
    vec3 tip = vTip[0];

    vec3 fwd = tip - tail;
    vec3 rgt = fwd.yxz * vec3(-1,1,1);

    gColor = vColor[0];

    // Main stroke
    gl_Position = projection * vec4(tail + 0.01 * rgt, 1.0);
    EmitVertex();
    gl_Position = projection * vec4(tail - 0.01 * rgt, 1.0);
    EmitVertex();
    gl_Position = projection * vec4(tip + 0.01 * rgt - 0.05 * fwd, 1.0);
    EmitVertex();
    gl_Position = projection * vec4(tip - 0.01 * rgt - 0.05 * fwd, 1.0);
    EmitVertex();
    EndPrimitive();

    // Arrow head
    gl_Position = projection * vec4((tip + 0.025 * rgt - 0.05 * fwd), 1.0);
    EmitVertex();
    gl_Position = projection * vec4(tip, 1.0);
    EmitVertex();
    gl_Position = projection * vec4((tip - 0.025 * rgt - 0.05 * fwd), 1.0);
    EmitVertex();
    EndPrimitive();
}

#elif defined FRAGMENT_SHADER

in vec3 gColor;
out vec4 outColor;

void main() {
    outColor = vec4(gColor,1);
}

#endif
