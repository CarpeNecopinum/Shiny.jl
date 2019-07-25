#if defined VERTEX_SHADER

struct Vertex {
    vec3 pos;
};

layout(std430) buffer vertices
{
    Vertex data[];
};

void main() {
    gl_Position = vec4(data[gl_VertexID].pos, 1.0);
}

#elif defined FRAGMENT_SHADER

out vec4 fColor;

void main() {
    fColor = vec4(1);
}

#endif
