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
	
	drawTexture_blendScreen4_fs4x.glsl
	Draw blended sample from multiple textures using screen function.
*/

#version 410

// ****TO-DO: 
//	0) copy existing texturing shader
//	1) declare additional texture uniforms
//	2) implement screen function with 4 inputs
//	3) use screen function to sample input textures

uniform sampler2D uImage00;

layout (location = 0) out vec4 rtFragColor;
in vec4 oTexCoord;

vec4 screen(vec4 input1, vec4 input2, vec4 input3, vec4 input4) 
{
	return 1-(1-input1)*(1-input2)*(1-input3)*(1-input4);
}

void main()
{
	vec4 image = texture2D(uImage00, oTexCoord.xy);
	rtFragColor = image;
	//rtFragColor = screen(image, )
}
