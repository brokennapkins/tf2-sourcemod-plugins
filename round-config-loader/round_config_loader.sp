/**
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * As a special exception, AlliedModders LLC gives you permission to link the
 * code of this program (as well as its derivative works) to "Half-Life 2," the
 * "Source Engine," the "SourcePawn JIT," and any Game MODs that run on software
 * by the Valve Corporation.  You must obey the GNU General Public License in
 * all respects for all other code used.  Additionally, AlliedModders LLC grants
 * this exception to all derivative works.  AlliedModders LLC defines further
 * exceptions, found in LICENSE.txt (as of this writing, version JULY-31-2007),
 * or <http://www.sourcemod.net/license.php>.
 *
 */

/**
 * Changelog
 *
 * 1.0 - initial version
 * 1.1 - replace deprecated FCVAR_PLUGIN
 */

#pragma semicolon 1

#include <sourcemod>

#define PLUGIN_VERSION "1.1"

new Handle:g_enabled = INVALID_HANDLE;

public Plugin:myinfo = {
	name = "Round Start/End Config Loader",
	author = "[OSF]Broken Napkins",
	description = "Execute server commands on round start/end.",
	version = PLUGIN_VERSION,
	url = "http://www.osfhome.com"
};

public OnPluginStart() {
	g_enabled = CreateConVar("sm_rloader_enable", "1", "Enable/trigger loading config on round start/end");
	CreateConVar("sm_rloader_version", PLUGIN_VERSION, "Version of L4D2 Team Chat Health Notificiations", FCVAR_REPLICATED|FCVAR_NOTIFY);
	HookEvent("round_start", Reload_Server_Config);
	HookEvent("round_end", Reload_Server_Config);
	HookEvent("player_left_start_area", Reload_Server_Config);
	
}

public Action:Reload_Server_Config(Handle:event, const String:name[], bool:dontBroadcast) {
	if(GetConVarBool(g_enabled)) {
		ServerCommand("exec server.cfg");
	}
}

