/**
 * MicroTF2 - Minigame C3
 * 
 * Avoid the trains!
 */

#define MC3_NUM 32
#define MC3_TRAINMDL "models/props_vehicles/train_enginecar.mdl"

int g_MC3Train1;
int g_MC3Train2;
int g_MC3Train1Mult;
int g_MC3Train2Mult;
bool g_MC3Train1Path;
bool g_MC3Train2Path;
int g_MC3Alpha;
bool g_MC3Rush;

public void MC3_EntryPoint()
{
	g_pfOnMinigameSelectedPre.AddFunction(INVALID_HANDLE, MC3_OnMinigameSelectedPre);
	g_pfOnMinigameSelected.AddFunction(INVALID_HANDLE, MC3_OnMinigameSelected);
	g_pfOnGameFrame.AddFunction(INVALID_HANDLE, MC3_OnGameFrame);
	g_pfOnMinigameFinish.AddFunction(INVALID_HANDLE, MC3_OnMinigameFinish);
	
	PrecacheModel(MC3_TRAINMDL);
}

public void MC3_OnMinigameSelectedPre()
{
	if(g_iActiveMinigameId == MC3_NUM)
	{
		g_MC3Train1 = MC3_CreateTrain(); g_MC3Train2 = MC3_CreateTrain();
		g_MC3Train1Mult = MC3_CreateTrainMult(); g_MC3Train2Mult = MC3_CreateTrainMult();
		g_MC3Rush = false;
		
		float pos[3];
		float ang[3] = {0.0, 0.0, 0.0};
		pos[2] = -320.0;
		
		int loc = GetRandomInt(0, 17);
		if(loc >= 9)
		{
			loc -= 9;
			pos[1] = -6624.0;
			ang[1] = 270.0;
			
			g_MC3Train1Path = true;
		}
		else
		{
			pos[1] = -8704.0;
			ang[1] = 90.0;
			
			g_MC3Train1Path = false;
		}
		
		pos[0] = -608.0 + (144.0 * float(loc));
		TeleportEntity(g_MC3Train1, pos, ang, NULL_VECTOR);
		TeleportEntity(g_MC3Train1Mult, pos, ang, NULL_VECTOR);
		
		loc = GetRandomInt(0, 17);
		if(loc >= 9)
		{
			loc -= 9;
			pos[0] = 1008.0;
			ang[1] = 180.0;
			
			g_MC3Train2Path = true;
		}
		else
		{
			pos[0] = -1072.0;
			ang[1] = 0.0;
			
			g_MC3Train2Path = false;
		}
		
		pos[1] = -8240.0 + (144.0 * float(loc));
		TeleportEntity(g_MC3Train2, pos, ang, NULL_VECTOR);
		TeleportEntity(g_MC3Train2Mult, pos, ang, NULL_VECTOR);
		
		g_MC3Alpha = 255;
		CreateTimer(0.5, MC3_TimerLoop, _, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void MC3_OnMinigameSelected(int client)
{
	if(g_iActiveMinigameId != MC3_NUM)
	{
		return;
	}

	if(!g_bIsMinigameActive)
	{
		return;
	}
	
	Player player = new Player(client);

	if(player.IsValid)
	{
		player.Class = TFClass_Scout;
		player.SetGodMode(false);
		player.SetCollisionsEnabled(false);
		player.ResetHealth();
		player.ResetWeapon(false);
	}
}

public Action MC3_TimerLoop(Handle timer)
{
	static int beat = 2;
	
	if(beat >= 3)
	{
		// rush!!
		
		MC3_SetAlpha(255);
		g_MC3Rush = true;
		SetVariantString("255 255 255");
		AcceptEntityInput(g_MC3Train1, "Color");
		SetVariantString("255 255 255");
		AcceptEntityInput(g_MC3Train2, "Color");
		
		beat = 2;
		return Plugin_Stop;
	}
	else
	{
		g_MC3Alpha = 255;
	}
	
	beat++;
	return Plugin_Continue;
}

public void MC3_OnGameFrame()
{
	if(g_iActiveMinigameId != MC3_NUM)
	{
		return;
	}

	if(!g_bIsMinigameActive)
	{
		return;
	}
	
	if(!IsValidEntity(g_MC3Train1) || !IsValidEntity(g_MC3Train2))
	{
		return;
	}
	
	// 4 beat red alert, and then forward!!!
	
	if(g_MC3Rush)
	{
		float pos[3];
		GetEntPropVector(g_MC3Train1, Prop_Send, "m_vecOrigin", pos);
		// move 2080 units
		if(pos[1] > -6624.0 || pos[1] < -8704.0)
		{
			RemoveEntity(g_MC3Train1);
			RemoveEntity(g_MC3Train1Mult);
		}
		else
		{
			if(g_MC3Train1Path) pos[1] += -50.0;
			else pos[1] += 50.0;
			TeleportEntity(g_MC3Train1, pos, NULL_VECTOR, NULL_VECTOR);
			TeleportEntity(g_MC3Train1Mult, pos, NULL_VECTOR, NULL_VECTOR);
		}
		
		GetEntPropVector(g_MC3Train2, Prop_Send, "m_vecOrigin", pos);
		if(pos[0] > 1008.0 || pos[0] < -1072.0)
		{
			RemoveEntity(g_MC3Train2);
			RemoveEntity(g_MC3Train2Mult);
		}
		else
		{
			if(g_MC3Train2Path) pos[0] += -50.0;
			else pos[0] += 50.0;
			TeleportEntity(g_MC3Train2, pos, NULL_VECTOR, NULL_VECTOR);
			TeleportEntity(g_MC3Train2Mult, pos, NULL_VECTOR, NULL_VECTOR);
		}
	}
	else
	{
		MC3_SetAlpha(g_MC3Alpha);
		g_MC3Alpha -= 13;
		if(g_MC3Alpha < 0) g_MC3Alpha = 0;
	}
}

public void MC3_OnMinigameFinish()
{
	if(g_iActiveMinigameId != MC3_NUM)
	{
		return;
	}

	if(!g_bIsMinigameActive)
	{
		return;
	}
	
	Player player;
	
	for(int i = 1; i <= MaxClients; i++)
	{
		player = new Player(i);
		
		if(player.IsValid && player.IsParticipating && player.Status != PlayerStatus_Failed)
		{
			player.TriggerSuccess();
		}
	}
}

public void MC3_OnStartTouch(const char[] output, int caller, int activator, float delay)
{
	Player player = new Player(activator);
	
	if(player.IsValid && player.IsParticipating)
	{
		player.Status = PlayerStatus_Failed;
		player.Kill();
	}
}

int MC3_CreateTrain()
{
	int ret;
	ret = CreateEntityByName("prop_dynamic");
	if(ret != -1)
	{
		DispatchKeyValue(ret, "model", MC3_TRAINMDL);
		DispatchKeyValue(ret, "rendermode", "1");
		DispatchKeyValue(ret, "rendercolor", "255 0 0");
		DispatchKeyValue(ret, "solid", "0");
		
		DispatchSpawn(ret);
	}
	
	return ret;
}

int MC3_CreateTrainMult()
{
	int ret;
	ret = CreateEntityByName("trigger_multiple");
	if(ret != -1)
	{
		DispatchKeyValue(ret, "spawnflags", "1");
		DispatchSpawn(ret);
		ActivateEntity(ret);
		float mins[3] = {-72.0, -304.0, -102.0};
		float maxs[3] = {72.0, 304.0, 102.0};
		SetEntPropVector(ret, Prop_Send, "m_vecMins", mins);
		SetEntPropVector(ret, Prop_Send, "m_vecMaxs", maxs);
		SetEntityModel(ret, MC3_TRAINMDL);
		SetEntProp(ret, Prop_Send, "m_nSolidType", 2);
		int enteffects = GetEntProp(ret, Prop_Send, "m_fEffects");
		enteffects |= 32;
		SetEntProp(ret, Prop_Send, "m_fEffects", enteffects);
		
		HookSingleEntityOutput(ret, "OnStartTouch", MC3_OnStartTouch);
	}
	
	return ret;
}

void MC3_SetAlpha(int alpha)
{
	if(!IsValidEntity(g_MC3Train1) || !IsValidEntity(g_MC3Train2))
	{
		return;
	}
	
	SetVariantInt(alpha);
	AcceptEntityInput(g_MC3Train1, "Alpha");
	SetVariantInt(alpha);
	AcceptEntityInput(g_MC3Train2, "Alpha");
}