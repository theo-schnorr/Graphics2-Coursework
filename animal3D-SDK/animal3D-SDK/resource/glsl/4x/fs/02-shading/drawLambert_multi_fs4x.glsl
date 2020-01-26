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
	
	drawLambert_multi_fs4x.glsl
	Draw Lambert shading model for multiple lights.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement Lambert shading model
//	Note: test all data and inbound values before using them!

in vec4 oMVNormie;
in vec4 oVSPos; 
in vec4 oTexCoord;

uniform Sampler2D uTex_dm;
uniform int uLightCt;
uniform float uLightSz;
uniform float uLightSzInvSq;
uniform float uLightPos;
uniform vec4 uLightCol;

out vec4 rtFragColor;


void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE RED
	rtFragColor = vec4(oMVNormie, 1.0);
}

