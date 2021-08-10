/**
 * MicroTF2 - Minigame C1
 * 
 * Say the Word! (Word or Color)
 */
 
char g_sMC1SayTextAnswers[][] =
{
	"빨강",
	"주황",
	"노랑",
	"초록",
	"파랑",
	"보라",
	"하양",
	"분홍"
};
char g_sMC1SayTextAnswersEng[][] =
{
	"레드",
	"오렌지",
	"옐로우",
	"그린",
	"블루",
	"퍼플",
	"화이트",
	"핑크"
};
int g_iMC1Answer = -1;
int g_iMC1Rng;
int g_MC1Color[4];
bool g_bMC1IsColor;
bool g_bMC1HasAnyPlayerWon = false;

Handle g_hHudSyncColor;

public void MC1_EntryPoint()
{
	g_pfOnMinigameSelectedPre.AddFunction(INVALID_HANDLE, MC1_OnMinigameSelectedPre);
	g_pfOnPlayerChatMessage.AddFunction(INVALID_HANDLE, MC1_OnChatMessage);
	
	if(g_hHudSyncColor != null) delete g_hHudSyncColor;
	g_hHudSyncColor = CreateHudSynchronizer();
}

public void MC1_OnMinigameSelectedPre()
{
	if (g_iActiveMinigameId == 30)
	{
		g_iMC1Answer = GetRandomInt(0, sizeof(g_sMC1SayTextAnswers) - 1);
		g_bMC1IsColor = view_as<bool>(GetRandomInt(0, 1));
		
		while((g_iMC1Rng = GetRandomInt(0, sizeof(g_sMC1SayTextAnswers) - 1)) == g_iMC1Answer)
		{
			g_iMC1Rng = GetRandomInt(0, sizeof(g_sMC1SayTextAnswers) - 1);
		}
		
		if(g_bMC1IsColor)
		{
			MC1_GetColor(g_iMC1Answer);
		}
		else
		{
			MC1_GetColor(g_iMC1Rng);
		}
		
		g_bMC1HasAnyPlayerWon = false;
	}
}

public void MC1_GetDynamicCaption(int client)
{
	Player player = new Player(client);
	
	if (player.IsInGame)
	{
		char text[64];
		Format(text, sizeof(text), g_bMC1IsColor ? "아래의 색깔을 입력하세요!" : "아래의 단어를 입력하세요!");
		player.SetCaption(text);
		
		SetHudTextParamsEx(-1.0, 0.26, 4.07, g_MC1Color, {0, 0, 0, 0}, 2, 0.0, 0.0, 0.0);
		//for(int i = 0; i < 5; i++)
		ShowSyncHudText(player.ClientId, g_hHudSyncColor, g_bMC1IsColor ? g_sMC1SayTextAnswers[g_iMC1Rng] : g_sMC1SayTextAnswers[g_iMC1Answer]);
	}
}

public Action MC1_OnChatMessage(int client, const char[] messageText, bool isTeamMessage)
{
	if (!g_bIsMinigameActive)
	{
		return Plugin_Continue;
	}

	if (g_iActiveMinigameId != 30)
	{
		return Plugin_Continue;
	}

	Player invoker = new Player(client);

	if (!invoker.IsParticipating)
	{
		return Plugin_Continue;
	}

	if (strcmp(messageText, g_sMC1SayTextAnswers[g_iMC1Answer]) == 0 ||
	strcmp(messageText, g_sMC1SayTextAnswersEng[g_iMC1Answer]) == 0)
	{
		invoker.TriggerSuccess();

		if (!g_bMC1HasAnyPlayerWon && Config_BonusPointsEnabled())
		{
			invoker.Score++;
			g_bMC1HasAnyPlayerWon = true;

			MC1_NotifyFirstPlayerComplete(invoker);
		}

		return Plugin_Handled;
	}

	return Plugin_Continue;
}

void MC1_NotifyFirstPlayerComplete(Player invoker)
{
	char name[64];
	
	if (invoker.Team == TFTeam_Red)
	{
		Format(name, sizeof(name), "{red}%N{default}", invoker.ClientId);
	}
	else if (invoker.Team == TFTeam_Blue)
	{
		Format(name, sizeof(name), "{blue}%N{default}", invoker.ClientId);
	}
	else
	{
		Format(name, sizeof(name), "{white}%N{default}", invoker.ClientId);
	}

	for (int i = 1; i <= MaxClients; i++)
	{
		Player player = new Player(i);

		if (player.IsValid && !player.IsBot)
		{
			player.PrintChatText("%T", "Minigame6_SayTheWord_PlayerSaidWordFirst", i, name);
		}
	}
}

void MC1_GetColor(int id)
{
	switch(id)
	{
		case 0:
		{
			g_MC1Color[0] = 255;
			g_MC1Color[1] = 0;
			g_MC1Color[2] = 0;
			g_MC1Color[3] = 255;
		}
		case 1:
		{
			g_MC1Color[0] = 252;
			g_MC1Color[1] = 161;
			g_MC1Color[2] = 3;
			g_MC1Color[3] = 255;
		}
		case 2:
		{
			g_MC1Color[0] = 252;
			g_MC1Color[1] = 240;
			g_MC1Color[2] = 3;
			g_MC1Color[3] = 255;
		}
		case 3:
		{
			g_MC1Color[0] = 4;
			g_MC1Color[1] = 173;
			g_MC1Color[2] = 46;
			g_MC1Color[3] = 255;
		}
		case 4:
		{
			g_MC1Color[0] = 0;
			g_MC1Color[1] = 101;
			g_MC1Color[2] = 209;
			g_MC1Color[3] = 255;
		}
		case 5:
		{
			g_MC1Color[0] = 152;
			g_MC1Color[1] = 50;
			g_MC1Color[2] = 219;
			g_MC1Color[3] = 255;
		}
		case 6:
		{
			g_MC1Color[0] = 255;
			g_MC1Color[1] = 255;
			g_MC1Color[2] = 255;
			g_MC1Color[3] = 255;
		}
		case 7:
		{
			g_MC1Color[0] = 255;
			g_MC1Color[1] = 138;
			g_MC1Color[2] = 249;
			g_MC1Color[3] = 255;
		}
	}
}