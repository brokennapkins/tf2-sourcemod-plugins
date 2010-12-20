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
 * 1.0 - initial trimmed version of connect announce. displays steam id of connecting
 *       player to admins
 *
 * 1.1 - clean up tag mismatch... OnClientPostAdminCheck is not supposed to have a
 *       return value
 * 1.2 - update author and url settings in myinfo
 */

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define MSGLENGTH 151
#define VERSION "1.2"

new Handle:cvarEnable;

public Plugin:myinfo =
{
	name = "Connect Announce Steam Lite",
	author = "[OSF]Broken Napkins",
	description = "Displays connect messages to admins including Steam ID of joining player",
	version = VERSION,
	url = "tf2.brokennapkins.com"
}

public OnPluginStart()
{
	cvarEnable = CreateConVar("sm_connect_announce_steam_lite_enable", "0", "Enable/Disable the plugin", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	CreateConVar("sm_connect_announce_steam_lite_version", "1.00", "Lite version of the Connect Announce plugin to show a player's Steam ID joining the server", FCVAR_REPLICATED);
}

public OnClientPostAdminCheck(client)
{
	if (GetConVarBool(cvarEnable)) {

		//save name
		decl String:name[32];
		GetClientName(client, name, sizeof(name));

		//save steam id
		decl String:auth[32];
		GetClientAuthString(client, auth, sizeof(auth));

		//send message to clients
		new iClients = GetClientCount();
		for (new i = 1; i <= iClients; i++) {
			if (IsClientInGame(i) && !IsFakeClient(i) && CheckCommandAccess(i, "sm_chat", ADMFLAG_CHAT)) {
				PrintToChat(i, "\x04Player %s (%s) has joined the game", name, auth);
			}
		}
	}
}