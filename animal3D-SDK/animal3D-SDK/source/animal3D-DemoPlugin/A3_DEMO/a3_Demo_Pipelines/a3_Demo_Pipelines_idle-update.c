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
	
	a3_Demo_Pipelines_idle-update.c
	Demo mode implementations: pipelines update.

	********************************************
	*** UPDATE FOR PIPELINES DEMO MODE       ***
	********************************************
*/

//-----------------------------------------------------------------------------

#include "../a3_Demo_Pipelines.h"

//typedef struct a3_DemoState a3_DemoState;
#include "../a3_DemoState.h"

#include "../_a3_demo_utilities/a3_DemoMacros.h"


//-----------------------------------------------------------------------------
// UPDATE

void a3pipelines_update(a3_DemoState* demoState, a3_Demo_Pipelines* demoMode, a3f64 dt)
{
	a3ui32 i;

	a3mat4* lightMVPptr, * lightMVPBptr;
	a3ui32 tmpLightCount, tmpBlockLightCount;

	a3_DemoPointLight* pointLight;

	// bias matrix
	const a3mat4 bias = {
		0.5f, 0.0f, 0.0f, 0.0f,
		0.0f, 0.5f, 0.0f, 0.0f,
		0.0f, 0.0f, 0.5f, 0.0f,
		0.5f, 0.5f, 0.5f, 1.0f,
	};

	// active camera
	a3_DemoProjector* activeCamera = demoState->projector + demoState->activeCamera;
	a3_DemoSceneObject* activeCameraObject = activeCamera->sceneObject;


	// send point light data
	pointLight = demoState->forwardPointLight;
	a3bufferRefill(demoState->ubo_pointLight, 0, demoState->forwardLightCount * sizeof(a3_DemoPointLight), pointLight);


	// update lights
	for (i = 0, pointLight = demoState->deferredPointLight + i,
		lightMVPptr = demoState->deferredLightMVP + i,
		lightMVPBptr = demoState->deferredLightMVPB + i;
		i < demoState->deferredLightCount;
		++i, ++pointLight, ++lightMVPptr, ++lightMVPBptr)
	{
		// set light scale and world position
		a3real4x4SetScale(lightMVPptr->m, pointLight->radius);
		lightMVPptr->v3 = pointLight->worldPos;

		// convert to view space and retrieve view position
		a3real4x4ConcatR(activeCameraObject->modelMatInv.m, lightMVPptr->m);
		pointLight->viewPos = lightMVPptr->v3;

		// complete by converting to clip space
		a3real4x4ConcatR(activeCamera->projectionMat.m, lightMVPptr->m);

		// calculate biased clip as well
		a3real4x4Product(lightMVPBptr->m, bias.m, lightMVPptr->m);
	}

	
	// upload buffer data
	tmpLightCount = demoState->deferredLightCount;
	if (tmpLightCount && demoMode->pipeline == pipelines_deferred_lighting)
	{
		demoState->deferredLightBlockCount = (tmpLightCount - 1) / demoStateMaxCount_lightVolumePerBlock + 1;
		for (i = 0, pointLight = demoState->deferredPointLight,
			lightMVPptr = demoState->deferredLightMVP, lightMVPBptr = demoState->deferredLightMVPB; i < demoState->deferredLightBlockCount;
			++i, tmpLightCount -= tmpBlockLightCount,
			pointLight += demoStateMaxCount_lightVolumePerBlock,
			lightMVPptr += demoStateMaxCount_lightVolumePerBlock, lightMVPBptr += demoStateMaxCount_lightVolumePerBlock)
		{
			// upload data for current light set
			tmpBlockLightCount = a3minimum(tmpLightCount, demoStateMaxCount_lightVolumePerBlock);
			demoState->deferredLightCountPerBlock[i] = tmpBlockLightCount;
			a3bufferRefill(demoState->ubo_transformMVP_light + i, 0, tmpBlockLightCount * sizeof(a3mat4), lightMVPptr);
			a3bufferRefill(demoState->ubo_transformMVPB_light + i, 0, tmpBlockLightCount * sizeof(a3mat4), lightMVPBptr);
			a3bufferRefill(demoState->ubo_pointLight + i, 0, tmpBlockLightCount * sizeof(a3_DemoPointLight), pointLight);
		}
	}
	else
	{
		demoState->deferredLightBlockCount = 0;
	}
}


//-----------------------------------------------------------------------------
