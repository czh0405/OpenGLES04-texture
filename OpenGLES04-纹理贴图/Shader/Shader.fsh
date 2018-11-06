precision mediump float;

uniform sampler2D image;
uniform sampler2D image2;

varying vec2 vTexcoord;

void main()
{
    gl_FragColor = mix (texture2D(image, vTexcoord), texture2D(image2, vTexcoord), 0.5);
}
