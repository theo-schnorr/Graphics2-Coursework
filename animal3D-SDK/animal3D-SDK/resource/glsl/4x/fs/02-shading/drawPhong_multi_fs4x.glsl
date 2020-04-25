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

//next part was taken from https://www.shadertoy.com/view/4ltSRS

//polygonDistance and the hashscales were directly copied, but numbers were changed for what we wanted
float polygonDistance(vec2 p, float radius, float angleOffset, int sideCount)
{
	float a = atan(p.x, p.y)+ angleOffset;
	float b = 6.28319 / float(sideCount);
	return cos(floor(.5 + a / b) * b - a) * length(p) - radius;
}

#define HASHSCALE1 443.8975
float hash11(float p) // assumes p in ~0-1 range
{
	vec3 p3  = fract(vec3(p) * HASHSCALE1);
    p3 += dot(p3, p3.yzx + 18.5);
    return fract((p3.x + p3.y) * p3.z);
}

#define HASHSCALE3 vec3(.1031, .1030, .0973)
vec2 hash21(float p) // assumes p in larger integer range
{
	vec3 p3 = fract(vec3(p) * HASHSCALE3);
	p3 += dot(p3, p3.yzx + 18.5);
	return fract(vec2((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y));
}


vec4 colorCurveInterpolation(vec4 pink, vec4 yellow, vec4 cyan, double time)
{
	vec4 p1 = mix(pink, cyan, cos(float(time)));
	vec4 p2 = mix(cyan, yellow, cos(float(time)));
	return mix(p1, p2, cos(float(time))/2.0+.5);
}

void main()
{
	/**Color Manipulation Stuff**/
	vec4 pink = vec4(1.0, 0.7, 1.0, 1.0);
	vec4 cyan = vec4(0.7, 1.0, 1.0, 1.0);
	vec4 yellow = vec4(1.0, 1.0, 0.7, 1.0);
	vec4 colorManip = colorCurveInterpolation(pink, yellow, cyan, uTime);
	/**Smoke Stuff**/
    float accum = 1.;
	//vec2 texSize = textureSize(uTex_dm, 2);
	//vec2 uv = (gl_FragCoord.xy / texSize);
	//uv.x *= texSize.x / texSize.y;

    for(int i = 0; i < 83; i++)
	{
        float fi = float(i);
        float thisYOffset = mod(hash11(fi * 0.017) * (float(uTime) + 19.) * 0.2, 4.0) - 2.0;
        vec2 center = (hash21(fi) * 2. - 1.) * vec2(1.1, 1.0) - vec2(0.0, thisYOffset);
        float radius = 0.3; //changes the radius of the dark portions
		//vec2 offset = uv - center; //this is the original shadertoy code, but we needed to change it
		vec2 offset =  vec2(0.5, .5) - (oTexCoord.xy / vec2(5000.0, 5000.0)) - center;
        float twistFactor = (hash11(fi * 0.0347) * 2. - 1.) * 1.9;
        float rotation = 0.1 + float(uTime) * 0.2 + sin(float(uTime) * 0.1) * 0.9 + (length(offset) / radius) * twistFactor;
        accum += pow(smoothstep(radius, 0.0, polygonDistance(offset, 0.1 + hash11(fi * 2.3) * 0.2, rotation, 5) + 0.1), 3.0);
    }
    
    vec3 subColor = vec3(0.5, 0.5, 0.5); //this is the color we need to take away from it

	vec4 smokeyColor  = vec4(vec3(1.0) - accum * subColor + colorManip.xyz, 1.0);
	rtFragColor = phong(oMVNormie, oVSPos, uTex_dm, uTex_sm, oTexCoord) * smokeyColor;
	//rtFragColor = smokeyColor;
}