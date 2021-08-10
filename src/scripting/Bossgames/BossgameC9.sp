/**
 * MicroTF2 - Bossgame C9
 * 
 * Jump Rope
 */

int g_BC9RotateBase;
float g_fBC9Speed;
float g_fBC9SpeedMult;
bool g_bBC9Phase;

public void BC9_EntryPoint()
{
	g_pfOnMinigameSelectedPre.AddFunction(INVALID_HANDLE, BC9_OnMinigameSelectedPre);
	g_pfOnMinigameSelected.AddFunction(INVALID_HANDLE, BC9_OnMinigameSelected);
	g_pfOnGameFrame.AddFunction(INVALID_HANDLE, BC9_OnGameFrame);
	g_pfOnPlayerDeath.AddFunction(INVALID_HANDLE, BC9_OnPlayerDeath);
	g_pfOnBossStopAttempt.AddFunction(INVALID_HANDLE, BC9_OnBossStopAttempt);
	g_pfOnMinigameFinish.AddFunction(INVALID_HANDLE, BC9_OnMinigameFinish);
}

public void BC9_OnMinigameSelectedPre()
{
	if(g_iActiveBossgameId == 9)
	{
		g_eDamageBlockMode = EDamageBlockMode_OtherPlayersOnly;
		
		g_BC9RotateBase = GetEntityByName("mc31_rope_base", "func_rotating");
		g_fBC9SpeedMult = 0.016666 * GetTickInterval() / 0.7;
	}
}

public void BC9_OnMinigameSelected(int client)
{
	if (g_iActiveBossgameId != 9)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	Player player = new Player(client);

	if (!player.IsValid)
	{
		return;
	}
	
	player.Class = TFClass_Scout;
	player.SetGodMode(false);
	player.Health = 64;
	player.ResetWeapon(false);
	player.SetCollisionsEnabled(false);
	
	float pos[3];
	float ang[3] = {0.0, 0.0, 0.0};
	float vel[3] = {0.0, 0.0, 0.0};
	int measure = client;
	
	pos[2] = -1946.0;
	if(measure > 16)
	{
		measure -= 16;
		
		ang[1] = 270.0;
		
		if(measure > 8)
		{
			measure -= 8;
			
			pos[1] = 5567.0;
		}
		else
		{
			pos[1] = 5503.0;
		}
		
		pos[0] = 5345.0 + ((measure-1) * 36);
	}
	else
	{
		ang[1] = 90.0;
		
		if(measure > 8)
		{
			measure -= 8;
			
			pos[1] = 4671.0;
		}
		else
		{
			pos[1] = 4735.0;
		}
		
		pos[0] = 4897.0 - ((measure-1) * 36);
	}
	
	TeleportEntity(client, pos, ang, vel);
	
	g_bBC9Phase = false;
	AcceptEntityInput(g_BC9RotateBase, "Start");
	g_fBC9Speed = 0.18;
}

public void BC9_OnGameFrame()
{
	if (g_iActiveBossgameId != 9)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	g_fBC9Speed += g_fBC9SpeedMult;
	if(g_fBC9Speed > 1.0) g_fBC9Speed = 1.0;
	
	if((Sine(DegToRad(270.0 + (g_fBC9Speed * 90.0))) + 1.0) * 0.7 >= 0.7)
	{
		g_bBC9Phase = true;
		g_fBC9Speed = 0.7;
		g_fBC9SpeedMult *= 0.7;
	}
	
	if(g_bBC9Phase) BC9_SetRopeSpeed(g_fBC9Speed);
	else BC9_SetRopeSpeed((Sine(DegToRad(270.0 + (g_fBC9Speed * 90.0))) + 1.0) * 0.7);
}

public void BC9_OnPlayerDeath(int client)
{
	if (g_iActiveBossgameId != 9)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	Player player = new Player(client);
	
	if (player.IsValid)
	{
		player.Status = PlayerStatus_Failed;
	}
}

public void BC9_OnBossStopAttempt()
{
	if (g_iActiveBossgameId != 9)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}

	int alivePlayers = 0;
	
	Player winner;

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && player.IsParticipating && player.IsAlive)
		{
			alivePlayers++;
			winner = player;
		}
	}

	if (alivePlayers <= 1)
	{
		AcceptEntityInput(g_BC9RotateBase, "Stop");
		
		winner.TriggerSuccess();
		
		float ang[3] = {0.0, 0.0, 0.0};
		TeleportEntity(g_BC9RotateBase, NULL_VECTOR, ang, NULL_VECTOR);
		EndBoss();
	}
}

public void BC9_OnMinigameFinish()
{
	if (g_iActiveBossgameId != 9)
	{
		return;
	}

	if (!g_bIsMinigameActive)
	{
		return;
	}
	
	float ang[3] = {0.0, 0.0, 0.0};
	TeleportEntity(g_BC9RotateBase, NULL_VECTOR, ang, NULL_VECTOR);
	
	Player player;
	for (int i = 1; i <= MaxClients; i++)
	{
		player = new Player(i);

		if (player.IsValid && player.IsParticipating && player.Status == PlayerStatus_NotWon)
		{
			player.TriggerSuccess();
		}
	}
}

void BC9_SetRopeSpeed(float per)
{
	if(!IsValidEntity(g_BC9RotateBase)) return;
	
	SetVariantFloat(per);
	AcceptEntityInput(g_BC9RotateBase, "SetSpeed");
}