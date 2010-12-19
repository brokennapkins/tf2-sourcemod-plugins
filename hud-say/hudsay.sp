/**
* 'HUD Say' for messages to all or to admins [31 Oct 09]
* For colored messages in games that support HUD text
*
* Description: (all messages to center of screen)
*	This pluging does two things currently: 
*	1. Displays a HUD message to all players in game
*    -OR-
*	2. Displays a HUD message to all admins in game
*
* Usage:
*	sm_hudsay [color] <message> - displays a HUD message to all players in game
*	sm_adminhudsay [color] <message> - displays a HUD message to all admins in game
*	
* Thanks to:
* 	MoggieX, author of Advanced Menu Say
*	
* Based upon:
*	Advanced Menu Say < nice walking skeleton code with some of my own cleanup
*  
* Version History
* 	1.0 - Let's have a go at it...
*	1.1 - Add admin specific HUD
*	1.2 - Reposition HUD to be just above cursor/crosshair
* 	
*/

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#define PLUGIN_VERSION "1.2"

new Handle:HudMessage;
new bool:CanHUD;
new Handle:g_cvars_HUDTIME;
new String:g_ColorNames[13][10] = {"WHITE", "RED", "GREEN", "BLUE", "YELLOW", "PURPLE", "CYAN", "ORANGE", "PINK", "OLIVE", "LIME", "VIOLET", "LIGHTBLUE"};
new g_Colors[13][3] = {{255,255,255},{255,0,0},{0,255,0},{0,0,255},{255,255,0},{255,0,255},{0,255,255},{255,128,0},{255,0,128},{128,255,0},{0,255,128},{128,0,255},{0,128,255}};

public Plugin:myinfo = {
	name = "HUD Say",
	author = "brokennapkins",
	description = "Colored HUD messages to all or to admins",
	version = PLUGIN_VERSION,
	url = "http://www.batheinfire.com/"
};


public OnPluginStart() {
	CreateConVar("sm_hudsay_version", PLUGIN_VERSION, "Display HUD messages to all players or admins only", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	RegAdminCmd("sm_hudsay", Command_SmHUDsay, ADMFLAG_CHAT, "sm_hudsay [color] <message>. Valid colors: WHITE, RED, GREEN, BLUE, YELLOW, PURPLE, CYAN, ORANGE, PINK, OLIVE, LIME, VIOLET, LIGHTBLUE");
	RegAdminCmd("sm_adminhudsay", Command_SmAdminHUDsay, ADMFLAG_CHAT, "sm_adminhudsay [color] <message>. Valid colors: WHITE, RED, GREEN, BLUE, YELLOW, PURPLE, CYAN, ORANGE, PINK, OLIVE, LIME, VIOLET, LIGHTBLUE");

	g_cvars_HUDTIME = CreateConVar("sm_hudsay_displaytime","5.0","How long the HUD messages are displayed.", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED);

	//verify game is supported
	new String:gamename[32];
	GetGameFolderName(gamename, sizeof(gamename));
	CanHUD = StrEqual(gamename,"tf",false) || StrEqual(gamename,"hl2mp",false) || StrEqual(gamename,"sourceforts",false) || StrEqual(gamename,"obsidian",false) || StrEqual(gamename,"left4dead",false) || StrEqual(gamename,"l4d",false);
	if(CanHUD) {
		HudMessage = CreateHudSynchronizer();
	}
}

public Action:Command_SmHUDsay(client, args){
	return SendHUD(client, args, "all");
}


public Action:Command_SmAdminHUDsay(client, args) {
	return SendHUD(client, args, "admin");
}

public Action:SendHUD(client, args, String:target[]) {
	decl String:CommandName[50];
	GetCmdArg(0, CommandName, sizeof(CommandName));
	
	if (args < 1) {
		ReplyToCommand(client, "[SM] Usage: %s [color] <message>. Valid colors: WHITE, RED, GREEN, BLUE, YELLOW, PURPLE, CYAN, ORANGE, PINK, OLIVE, LIME, VIOLET, LIGHTBLUE", CommandName);
		return Plugin_Handled;	
	}	

	//get args
	decl String:text[192], String:colorStr[16], String:trimmed_text[192];
	GetCmdArgString(text, sizeof(text));

	//find index of beginning of message
	new len = BreakString(text, colorStr, 16);

	//find the optional color string
	new color = FindColor(colorStr);
	if (color == -1) {
		color = 0;
		len = 0;
	}
	
	//strip quotes off message
	strcopy(trimmed_text, sizeof(trimmed_text), text[len]);
	StripQuotes(trimmed_text);
	
	//send message to clients
	new iClients = GetClientCount();
	for (new i = 1; i <= iClients; i++) {
		if (
			IsClientInGame(i) && !IsFakeClient(i) &&
			(
				StrEqual(target, "all", false) ||
				(StrEqual(target, "admin", false) && CheckCommandAccess(i, "sm_chat", ADMFLAG_CHAT))
			)
		) {
			SetHudTextParams(-1.0, 0.45, GetConVarFloat(g_cvars_HUDTIME), g_Colors[color][0], g_Colors[color][1], g_Colors[color][2], 255);
			ShowSyncHudText(i, HudMessage, trimmed_text);
		}
	}

	return Plugin_Handled;

}

FindColor(String:color[]) {
	for (new i = 0; i < 13; i++) {
		if (strcmp(color, g_ColorNames[i], false) == 0) {
			return i;
		}
	}
	
	return -1;
}