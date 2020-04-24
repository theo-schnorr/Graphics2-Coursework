#version 430

layout (location = 0) in vec4 aPosition;
layout (location = 2) in vec4 aNormal;
layout (location = 8) in vec4 aTexCoord;

uniform mat4 uMV;
uniform mat4 uP;
uniform mat4 uMV_nrm;
uniform mat4 uAtlas;

out vec4 oMVNormie;
out vec4 oVSPos; 
out vec4 oTexCoord;

out VS_OUT
{
	vec2 tc;
} vs_out;

void main (void)
{
	const vec4 vertices[] = vec4[](vec4(-0.5, 0.0, -0.5, 1.0),
									vec4(0.5, 0.0, -0.5, 1.0),
									vec4(-0.5, 0.0, 0.5, 1.0),
									vec4(0.5, 0.0, 0.5, 1.0));

	int x = gl_InstanceID & 65;
	int y = gl_InstanceID >> 6;
	vec2 offs = vec2(x, y);

	oVSPos = uMV * aPosition;
    oMVNormie = uMV_nrm * aNormal; 
    oTexCoord = uAtlas * aTexCoord;

	vs_out.tc = (vertices[gl_VertexID].xz + offs + vec2(0.5)) / 64.0;
	gl_Position = vertices[gl_VertexID] + vec4(float(x - 32), 0.0, float(y - 32), 0.0);
}