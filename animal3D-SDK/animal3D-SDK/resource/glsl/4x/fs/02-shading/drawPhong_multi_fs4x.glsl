/*
	Copyright 2011-2020 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawPhong_multi_fs4x.glsl
	Draw Phong shading model for multiple lights.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variables for textures; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement Phong shading model
//	Note: test all data and inbound values before using them!

in vec4 oMVNormie;
in vec4 oVSPos; 
in vec4 oTexCoord;

uniform sampler2D uTex_dm;
uniform int uLightCt;
uniform float uLightSz;
uniform float uLightSzInvSq;
uniform vec4 uLightPos[4];
uniform vec4 uLightCol[4];

out vec4 rtFragColor;

float diffuse(vec4 n, vec4 l, vec4 pos);
float specular(vec4 viewer, vec4 pos, vec4 n, vec4 l, float shinyConstant);

void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE GREEN
	// phong = diffuse + specular + ambient;
	vec4 normalizedN = normalize(oMVNormie);
	vec4 phong  = vec4(0.0,0.0,0.0, 0.0);

	for(int i = 0; i  < uLightCt; i++)
	{
		phong += (diffuse(normalizedN, uLightPos[i], oVSPos)*uLightCol[i] + specular(-oVSPos, oVSPos, normalizedN, uLightPos[i], 1.0));
	}

	rtFragColor = phong  * texture(uTex_dm, oTexCoord.xy);
}


float diffuse(vec4 n, vec4 l, vec4 pos)
{
	vec4 normalizedL = normalize(l-pos);
	float dotPro = dot(n, normalizedL);
	
	return dotPro;
}

float specular(vec4 viewerPos, vec4 pos, vec4 n, vec4 l, float shinyConstant)
{
	vec4 normalizedViewer = normalize(viewerPos - pos);
	vec4 normalizedLight = normalize(l-pos);
	vec4 normalizedReflection = 2 * diffuse(n, l, pos) * n - normalizedLight;
	float specular = pow(dot(normalizedViewer, normalizedReflection), shinyConstant); //we dont know what the shiny constant should be (what uniform)

	return specular;
}
