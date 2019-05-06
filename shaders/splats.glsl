#if defined VERTEX_SHADER
in vec3 position;
in vec3 normal;

#ifdef COLOR_PER_SPLAT
in vec3 color;
out vec3 vColor;
#endif

#ifdef RADIUS_PER_SPLAT
in float radius;
out float vRadius;
#endif

out vec3 vCenter;
out vec3 vNormal;

void main() {
    vNormal = normal;
    vCenter = position;

    #ifdef COLOR_PER_SPLAT
    vColor = color;
    #endif

    #ifdef RADIUS_PER_SPLAT
    vRadius = radius;
    #endif
}



#elif defined GEOMETRY_SHADER
layout (points) in;
layout (triangle_strip, max_vertices = 3) out;

// input attributes
in vec3 vCenter[];
in vec3 vNormal[];

#ifdef COLOR_PER_SPLAT
in vec3 vColor[];
out vec3 gsColor;
#endif

#ifdef RADIUS_PER_SPLAT
in float vRadius[];
const float radius = vRadius[0];
#else
uniform float radius;
#endif

out vec2 gsQuadCoords;

uniform mat4 modelview;
uniform mat4 projection;

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

bool out_of_frustum(vec4 p)
{
    vec4 proj = projection * p;
    proj.xyz /= proj.w;
    return any(greaterThan(abs(proj.xyz), vec3(1.0)));
}

void main(void)
{
    #ifdef COLOR_PER_SPLAT
    gsColor = vColor[0];
    #endif

    vec3 p = vec3(modelview * vec4(vCenter[0], 1));
    vec3 n = mat3(modelview) * vNormal[0];
    vec3 r = normalize(perpendicular(n));
    //vec3 r = normalize(cross(n, vec3(0,1,0)));
    vec3 u = cross(n, r);

    r = radius * normalize(r);
    u = radius * normalize(u);

    if (out_of_frustum(vec4(p - r, 1.0)) &&
        out_of_frustum(vec4(p + r, 1.0)) &&
        out_of_frustum(vec4(p - u, 1.0)) &&
        out_of_frustum(vec4(p + u, 1.0))) return;

    vec2 uv;

    uv = vec2(0,2);
    gsQuadCoords = uv;
    gl_Position = projection * vec4(p + uv.x * r + uv.y * u, 1.0);
    EmitVertex();

    uv = vec2(-1.73205,-1);
    gsQuadCoords = uv;
    gl_Position = projection * vec4(p + uv.x * r + uv.y * u, 1.0);
    EmitVertex();

    uv = vec2(1.73205,-1);
    gsQuadCoords = uv;
    gl_Position = projection * vec4(p + uv.x * r + uv.y * u, 1.0);
    EmitVertex();
}



#elif defined FRAGMENT_SHADER
#ifdef COLOR_PER_SPLAT
in vec3 gsColor;
#else
uniform vec3 color;
const vec3 gsColor = color;
#endif
in vec2 gsQuadCoords;

out vec4 outColor;
void main() {
    if (dot(gsQuadCoords, gsQuadCoords) > 1) discard;

    vec3 col = gsColor; //.bgr / 255;

    outColor = vec4(col, 1.0);
}
#endif
