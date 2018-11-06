precision mediump float;

uniform sampler2D image;

varying vec2 vTexcoord;
varying vec3 vColor;

void main()
{
    gl_FragColor = texture2D(image, vTexcoord) * vec4(vColor, 1.0);
}
