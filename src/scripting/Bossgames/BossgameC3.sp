/**
 * MicroTF2 - Bossgame C3
 * 
 * Goal 7 Bombs
 */

#define BC3_NUM 11

int g_iBC3Points[MAXPLAYERS + 1];
int g_eBC3Goal;

public void BC3_EntryPoint()
{
	g_pfOnMinigameSelectedPre.AddFunction(INVALID_HANDLE, BC3_OnMinigameSelectedPre);
	g_pfOnMinigameSelected.AddFunction(INVALID_HANDLE, BC3_OnMinigameSelected);
	g_pfOnMinigameFinish.AddFunction(INVALID_HANDLE, BC3_OnMinigameFinish);
	g_pfOnEntityCreated.AddFunction(INVALID_HANDLE, BC3_OnEntityCreated);
}

public void BC3_OnMinigameSelectedPre()
{
	if(g_iActiveBossgameId == BC3_NUM)
	{
		for(int i = 1; i <= MaxClients; i++)
		{
			g_iBC3Points[i] = 0;
		}
	}
}

public void BC3_OnMinigameSelected()
{
	if (g_iActiveBossgameId != BC1_NUM)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	// teleport
	
	// demo, steel bomb
}

public void BC3_OnEntityCreated(int entity, const char[] cls)
{
	if (g_iActiveBossgameId != BC3_NUM)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	if(StrEqual(cls, "tf_projectile_pipe"))
	{
		SDKHook(entity, SDKHook_StartTouchPost, BC3_PipeStartTouchPost);
	}
}

public void BC3_OnMinigameFinish(int client)
{
	
}

public void BC3_PipeStartTouchPost(int entity, int other)
{
	char cls[16]; GetEntityClassname(other, cls, sizeof(cls));
	if(StrEqual(cls, "func_button"))
	{
		Player player = new Player(GetEntPropEnt(entity, Prop_Send, "m_hThrower"));
		
		if(player.Status == PlayerStatus_NotWon)
		{
			g_iBC3Points[player.ClientId]++;
			if(g_iBC3Points[player.ClientId] >= 7)
			{
				player.TriggerSuccess();
			}
		}
		
		RemoveEntity(entity);
	}
}