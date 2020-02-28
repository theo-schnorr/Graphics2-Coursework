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
	
	drawPhong_multi_deferred_fs4x.glsl
	Draw Phong shading model by sampling from input textures instead of 
		data received from vertex shader.
*/

#version 410

#define MAX_LIGHTS 4

// ****TO-DO: 
//	0) copy original forward Phong shader
//	1) declare g-buffer textures as uniform samplers
//	2) declare light data as uniform block
//	3) replace geometric information normally received from fragment shader 
//		with samples from respective g-buffer textures; use to compute lighting
//			-> position calculated using reverse perspective divide; requires 
//				inverse projection-bias matrix and the depth map
//			-> normal calculated by expanding range of normal sample
//			-> surface texture coordinate is used as-is once sampled

in vbLightingData {
	vec4 vViewPosition;
	vec4 vViewNormal;
	vec4 vTexcoord;
	vec4 vBiasedClipCoord;
};

uniform sampler2D defaultTexUnits[16];

uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;
uniform int uLightCt;
uniform float uLightSz;
uniform float uLightSzInvSq;
uniform vec4 uLightPos[4];
uniform vec4 uLightCol[4];

layout (location = 0) out vec4 rtFragColor;
layout (location = 4) out vec4 rtDiffuseMapSample;
layout (location = 5) out vec4 rtSpecularMapSample;
layout (location = 6) out vec4 rtDiffuseLightTotal;
layout (location = 7) out vec4 rtSpecularLightTotal;

float diffuse(vec4 n, vec4 l, vec4 pos);
float specular(vec4 viewer, vec4 pos, vec4 n, vec4 l, float shinyConstant);


//lab6
vec4 unpackTextures(sampler2D ogPos, vec2 coord) 
{
	return texelFetch(ogPos, ivec2(coord), 0);  //attempting to unpack
	//we don't understand how to unpack it without unpacking the tex coord first, but to do that we need to unpack it using the texcoord
	//this is based on the superbible code
}


void main()
{


	// phong = diffuse + specular + ambient;
	vec4 normalizedN = normalize(vViewNormal);
	vec4 phong  = vec4(0.0,0.0,0.0, 0.0);
	vec4 diffuseColor = vec4(0.0, 0.0, 0.0, 1.0);
	vec4 specularColor = vec4(0.0, 0.0, 0.0, 1.0);
	vec4 diffuseTex;
	vec4 specularTex;

	for(int i = 0; i  < uLightCt; i++)
	{
		// Diffuse color and diffuse texture
		diffuseColor += diffuse(normalizedN, uLightPos[i], vViewPosition) * uLightCol[i];
		// Specular color and specular texture
		specularColor += specular(vec4(0.0, 0.0, 0.0, 1.0), vViewPosition, normalizedN, uLightPos[i], 128.0) * uLightCol[i];
	}

	diffuseTex = diffuseColor * texture(uTex_dm, vTexcoord.xy);
	specularTex = specularColor * texture(uTex_sm, vTexcoord.xy);

	// DUMMY OUTPUT: all fragments are OPAQUE CYAN (and others)
	rtFragColor = phong;
	rtDiffuseMapSample = texture(uTex_dm, vTexcoord.xy);
	rtSpecularMapSample = texture(uTex_sm, vTexcoord.xy);
	rtDiffuseLightTotal = diffuseColor;
	rtSpecularLightTotal = specularColor;
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