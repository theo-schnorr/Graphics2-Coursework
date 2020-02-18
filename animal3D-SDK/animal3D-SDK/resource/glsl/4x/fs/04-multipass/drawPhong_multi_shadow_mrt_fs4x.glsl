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
	
	drawPhong_multi_shadow_mrt_fs4x.glsl
	Draw Phong shading model for multiple lights with MRT output and 
		shadow mapping.
*/

#version 410

// ****TO-DO: 
//	0) copy existing Phong shader
//	1) receive shadow coordinate
//	2) perform perspective divide
//	3) declare shadow map texture
//	4) perform shadow test

in vec4 oMVNormie;
in vec4 oVSPos; 
in vec4 oTexCoord;
in vec4 oShadowCoord;

uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;
uniform int uLightCt;
uniform float uLightSz;
uniform float uLightSzInvSq;
uniform vec4 uLightPos[4];
uniform vec4 uLightCol[4];

// lab 4
uniform sampler2D uTex_shadow;

// lab 3
layout (location = 0) out vec4 rtFragColor;
layout (location = 1) out vec4 rtPosition;
layout (location = 2) out vec4 rtNormal;
layout (location = 3) out vec4 rtTexCoord;
layout (location = 4) out vec4 rtDiffuseTex;
layout (location = 5) out vec4 rtSpecularTex;
layout (location = 6) out vec4 rtDiffuseLight;
layout (location = 7) out vec4 rtSpecularLight;

float diffuse(vec4 n, vec4 l, vec4 pos);
float specular(vec4 viewer, vec4 pos, vec4 n, vec4 l, float shinyConstant);

void main()
{
	// phong = diffuse + specular + ambient;
	vec4 normalizedN = normalize(oMVNormie);
	vec4 phong  = vec4(0.0,0.0,0.0, 0.0);
	vec4 diffuseColor = vec4(0.0, 0.0, 0.0, 1.0);
	vec4 specularColor = vec4(0.0, 0.0, 0.0, 1.0);
	vec4 diffuseTex;
	vec4 specularTex;

	for(int i = 0; i  < uLightCt; i++)
	{
		// Diffuse color and diffuse texture
		diffuseColor += diffuse(normalizedN, uLightPos[i], oVSPos) * uLightCol[i];
		// Specular color and specular texture
		specularColor += specular(vec4(0.0, 0.0, 0.0, 1.0), oVSPos, normalizedN, uLightPos[i], 128.0) * uLightCol[i];
	}

	diffuseTex = diffuseColor * texture(uTex_dm, oTexCoord.xy);
	specularTex = specularColor * texture(uTex_sm, oTexCoord.xy);

	phong  = diffuseTex + specularTex;

	// lab 4
	vec4 perspecDivide = oShadowCoord / oShadowCoord.w;
	float shadowDepth = texture(uTex_shadow, perspecDivide.xy).r;

	if( perspecDivide.z > (shadowDepth + .0025))
	{
		phong *= 0.2;
	}


	rtFragColor = phong;

	// lab 3
	rtPosition = oVSPos;
	rtNormal = normalizedN;
	rtTexCoord = oTexCoord;
	rtDiffuseTex = texture(uTex_dm, oTexCoord.xy);
	rtSpecularTex = texture(uTex_sm, oTexCoord.xy);
	rtDiffuseLight = diffuseColor;
	rtSpecularLight = specularColor;
}


float diffuse(vec4 n, vec4 l, vec4 pos)
{
	vec4 normalizedL = normalize(l-pos);
	float dotPro = max(dot(n, normalizedL), 0.0);
	
	return dotPro;
}

float specular(vec4 viewerPos, vec4 pos, vec4 n, vec4 l, float shinyConstant)
{
	vec4 normalizedViewer = normalize(viewerPos - pos);
	vec4 normalizedLight = normalize(l-pos);
	vec4 normalizedReflection = reflect(-normalizedLight,n);
	float specular = pow(max(dot(normalizedReflection, normalizedViewer), 0.0), shinyConstant);
	
	return specular;
}