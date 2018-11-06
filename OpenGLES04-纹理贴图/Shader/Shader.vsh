attribute vec3 position;
attribute vec2 texcoord;
attribute vec3 color;

varying vec2 vTexcoord;
varying vec3 vColor;

void main()
{
    gl_Position = vec4(position, 1.0);
    vTexcoord = texcoord;
    vColor = color;
}
