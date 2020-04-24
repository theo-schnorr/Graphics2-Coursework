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

//uniform sampler2D uSmokeTex_dm;
//uniform sampler2D uSmokeTex_sm;
uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;
uniform int uLightCt;
uniform vec4 uLightPos[4];
uniform vec4 uLightCol[4];
uniform double uTime;

out vec4 rtFragColor;

float diffuse(vec4 n, vec4 l, vec4 pos)
{
	vec4 normalizedL = normalize(l-pos);
	return max(dot(n, normalizedL), 0.0);
}

float specular(vec4 viewerPos, vec4 pos, vec4 n, vec4 l, float shinyConstant)
{
	vec4 normalizedViewer = normalize(viewerPos - pos);
	vec4 normalizedLight = normalize(l-pos);
	vec4 normalizedReflection = reflect(-normalizedLight, n);
	//return pow(max(dot(normalizedReflection, normalizedViewer), 0.0), shinyConstant); 
	//i want to try something different, if it doesnt work we go to the old one
	return pow(dot(normalizedReflection, normalizedViewer)/2.0+.5, shinyConstant);
}

vec4 phong(vec4 normie, vec4 viewSpacePos, sampler2D diffuseTex, sampler2D specularTex, vec4 texCoord)
{
	vec4 normalizedN = normalize(normie);
	vec4 phong = vec4(0.0,0.0,0.0,0.0);

	for(int i=0; i< uLightCt; i++)
	{
		vec4 diffuse = diffuse(normalizedN, uLightPos[i], viewSpacePos) * uLightCol[i]* texture(diffuseTex, texCoord.xy);
		vec4 specular = specular(vec4(0.0,0.0,0.0,1.0), viewSpacePos, normalizedN, uLightPos[i], 128.0) * texture(specularTex, texCoord.xy);
		phong += (diffuse + specular);
	}
	return phong;
}

vec4 colorCurveInterpolation(vec4 pink, vec4 yellow, vec4 cyan, double time)
{
	vec4 p1 = mix(pink, cyan, cos(float(time)));
	vec4 p2 = mix(cyan, yellow, cos(float(time)));
	return mix(p1, p2, cos(float(time))/2.0+.5);
}

void main()
{
	vec4 pink = vec4(1.0, 0.7, 1.0, 1.0);
	vec4 cyan = vec4(0.7, 1.0, 1.0, 1.0);
	vec4 yellow = vec4(1.0, 1.0, 0.7, 1.0);
	//rtFragColor = pink;
	//rtFragColor = colorCurveInterpolation(pink, yellow, cyan, uTime);
	rtFragColor = phong(oMVNormie, oVSPos, uTex_dm, uTex_sm, oTexCoord) * colorCurveInterpolation(pink, yellow, cyan, uTime);
	//rtFragColor = phong(oMVNormie, uLightCt, uLightPos, oVSPos, uLightCol, uSmokeTex_dm, uSmokeTex_sm, oTexCoord);
}