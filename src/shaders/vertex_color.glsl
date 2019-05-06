#if defined VERTEX_SHADER
in vec3 position;
in vec3 color;
uniform mat4 modelviewprojection;
out vec3 vColor;
void main() {
    vColor = color;
    gl_Position = modelviewprojection * vec4(position, 1.0);
    gl_PointSize = 1; // max(1, 5 / gl_Position.w);
}

#elif defined FRAGMENT_SHADER
in vec3 vColor;
out vec4 outColor;
void main() {
    vec3 col = vColor; // vColor.bgr / 255;
    //col = pow(col, vec3(1.0 / 2.2));

    outColor = vec4(col, 1.0);
}

#endif
