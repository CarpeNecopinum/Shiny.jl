#if defined VERTEX_SHADER
in vec3 position;
in vec3 normal;
in vec3 color;

out vec3 vColor;
out vec3 vCenter;
out vec3 vNormal;

void main() {
    vNormal = normal;
    vColor = color;
    vCenter = position;
}

#elif defined TESSELATION_CONTROL_SHADER

layout (vertices = 4) out;

in vec3 vCenter[];
in vec3 vNormal[];
in vec3 vColor[];

out vec3 tcColor[];
out vec4 tcPosition[];

uniform mat4 modelview;
uniform mat4 projection;

uniform float radius = 0.05;

const vec2 uvs[] = {
    vec2(-1,-1),
    vec2(-1,1),
    vec2(1,1),
    vec2(1,-1)};


vec3 perpendicular( const vec3 v )
{
    if ( abs(v.x) < abs(v.y) )
    {
        if (abs(v.x) < abs(v.z))
            return normalize( vec3(1.0f - v.x * v.x, -v.x * v.y, -v.x * v.z) );
    } else
    {
        if (abs(v.y) < abs(v.z))
            return normalize( vec3(-v.y * v.x, 1.0f - v.y * v.y, -v.y * v.z) );
    }
    return normalize( vec3(-v.z * v.x, -v.z * v.y, 1.0f - v.z * v.z) );
}

bool out_of_frustum(vec4 proj)
{
    proj.xyz /= proj.w;
    return any(greaterThan(abs(proj.xyz), vec3(1.0)));
}

void main(void)
{
    if (gl_InvocationID == 0) {
        gl_TessLevelOuter[0] = 1;
        gl_TessLevelOuter[1] = 1;
        gl_TessLevelOuter[2] = 1;
        gl_TessLevelOuter[3] = 1;
        gl_TessLevelInner[0] = 1;
        gl_TessLevelInner[1] = 1;
    }

    // pass color
    tcColor[gl_InvocationID] = vColor[0];

    vec3 p = vec3(modelview * vec4(vCenter[0], 1));
    vec3 n = mat3(modelview) * vNormal[0];
    vec3 r = normalize(perpendicular(n));
    //vec3 r = normalize(cross(n, vec3(0,1,0)));
    vec3 u = cross(n, r);

    r = radius * normalize(r);
    u = radius * normalize(u);

    vec2 uv = uvs[gl_InvocationID];
    tcPosition[gl_InvocationID] = projection * vec4(p + uv.x * r + uv.y * u, 1.0);

    //gl_TessLevelOuter[gl_InvocationID] = out_of_frustum(tcPosition[gl_InvocationID]) ? -1.0 : 1.0;
}

#elif defined TESSELATION_EVALUATION_SHADER

layout(quads, cw) in;

in vec3 tcColor[];
in vec4 tcPosition[];


out vec3 teColor;
out vec2 teQuadCoords;

void main() {
    teColor = tcColor[0];

    // vec3 p = mix(
    //     mix(tcPosition[0], tcPosition[3], gl_TessCoord.x),
    //     mix(tcPosition[1], tcPosition[2], gl_TessCoord.x),
    //     gl_TessCoord.y);

    vec4 p = (1.0 - gl_TessCoord.x) * (1.0 - gl_TessCoord.y) * tcPosition[0]
           + (      gl_TessCoord.x) * (1.0 - gl_TessCoord.y) * tcPosition[1]
           + (      gl_TessCoord.x) * (      gl_TessCoord.y) * tcPosition[2]
           + (1.0 - gl_TessCoord.x) * (      gl_TessCoord.y) * tcPosition[3];


    gl_Position = p;
    teQuadCoords = gl_TessCoord.xy * 2 - 1;
}

#elif defined FRAGMENT_SHADER
in vec3 teColor;
in vec2 teQuadCoords;

out vec4 outColor;
void main() {
    if (dot(teQuadCoords, teQuadCoords) > 1) discard;

    vec3 col = teColor.bgr / 255;
    outColor = vec4(col, 1.0);
}
#endif
