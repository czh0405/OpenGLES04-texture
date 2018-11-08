attribute vec3 position;
attribute vec2 texcoord;

uniform mat4 transform;

varying vec2 vTexcoord;

void main()
{
    gl_Position = transform * vec4(position, 1.0);
    vTexcoord = texcoord;
}
