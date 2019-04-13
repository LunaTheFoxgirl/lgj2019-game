#version 330

precision highp float;

uniform sampler2D ppTexture;
in vec4 exColor;
in vec2 exTexcoord;
out vec4 outColor;

void main(void) {
	vec4 tex_col = texture2D(ppTexture, exTexcoord);
    if (tex_col.a < 0.8) discard;
	outColor = exColor * tex_col;
}
