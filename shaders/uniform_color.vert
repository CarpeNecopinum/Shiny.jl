#version 450 core

in vec3 position;
uniform mat4 modelviewprojection;
void main() {
    gl_Position = modelviewprojection * vec4(position, 1.0);
}
