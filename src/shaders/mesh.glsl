#ifdef VERTEX_SHADER
in vec3 position;

#ifdef COLOR_PER_VERTEX
in vec3 color;
out vec3 vColor;
#endif

uniform mat4 modelview;
uniform mat4 projection;

out vec3 vPosition;

void main() {
    vPosition = (modelview * vec4(position, 1.0)).xyz;
    gl_Position = projection * modelview * vec4(position, 1.0);

    #ifdef COLOR_PER_VERTEX
    vColor = color;
    #endif
}

#elif defined FRAGMENT_SHADER

in vec3 vPosition;

#ifdef COLOR_PER_VERTEX
in vec3 vColor;
#else
uniform vec3 color;
const vec3 vColor = color;
#endif

out vec4 fColor;

void main() {
    vec3 normal = normalize(cross(dFdx(vPosition), dFdy(vPosition)));
    fColor = vec4((0.9 * normal.z + 0.1) * vColor, 1.0);
}

#endif
