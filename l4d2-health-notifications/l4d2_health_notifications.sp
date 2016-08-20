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
 
/**
 * color codes
 * \x01 = white
 * \x02 = white
 * \x03 = lightgreen
 * \x04 = yellow
 * \x05 = olivegreen
 */

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>

#define PLUGIN_VERSION "1.1"

#define HEALTH_HIGH 100
#define HEALTH_MED 39
#define HEALTH_LOW 24
#define SURVIVOR_TEAM 2

new Handle:cvarEnabled = INVALID_HANDLE;
new Handle:cvarMsgType = INVALID_HANDLE;
new enabled;
new msgType;

public Plugin:myinfo = {
	author = "[OSF]Broken Napkins",
	description = "Notify players in team chat or hint box when a player changes between health levels or goes black and white",
	name = "L4D2 Health Notificiations",
	url = "http://www.osfhome.com",
	version = PLUGIN_VERSION
};

public OnPluginStart() {
	/**
	 * convars
	 */
	cvarEnabled = CreateConVar("l4d2_health_notifications_enable", "0", "Enable/Disable the plugin", FCVAR_NONE, true, 0.0, true, 1.0);
	cvarMsgType = CreateConVar("l4d2_health_notifications_type", "1", "0 prints to chat, 1 displays hint box.", FCVAR_NONE, true, 0.0, true, 1.0);
	CreateConVar("l4d2_health_notifications_version", PLUGIN_VERSION, "Version of L4D2 Team Chat Health Notificiations", FCVAR_REPLICATED|FCVAR_NOTIFY);
	/**
	 * event hooks
	 */
	HookEvent("revive_success", NotifySurvivorsOnReviveSuccess);
	HookEvent("heal_success", NotifySurvivorsOnHealSuccess);
	HookEvent("player_hurt", NotifySurvivorsOnPlayerHurt);
	//HookEvent("player_death", NotifySurvivors);
	//HookEvent("player_incapacitated", NotifySurvivors);
	/**
	 * read initial convar values
	 */
	enabled = GetConVarBool(cvarEnabled);
	msgType = GetConVarInt(cvarMsgType);
	/**
	 * listen for changes to the available convars
	 */
	HookConVarChange(cvarEnabled, ChangeVars);
	HookConVarChange(cvarMsgType, ChangeVars);
}

/**
 * handle a player going black and white when revived
 */
public NotifySurvivorsOnReviveSuccess(Handle:event, const String:name[], bool:dontBroadcast) {
	if (!enabled) {
		return;
	}
	new target = GetClientOfUserId(GetEventInt(event, "subject"));
	new lastLife = GetEventBool(event, "lastlife");
	decl String:targetName[64];
	GetClientName(target, targetName, sizeof(targetName));
	int health = GetClientHealth(target);
	/**
	 * make sure the target of the event is a survivor who's in game
	 */
	if (target <= 0 || !IsClientInGame(target) || GetClientTeam(target) != SURVIVOR_TEAM) {
		return;
	}
	/**
	 * notify survivors on the target's team
	 */
	if (lastLife) {
		if (msgType == 1) {
			PrintHintTextToAll("\x04WARNING: %s is \x01black and white \x04with a health of %i.", targetName, health);
		} else {
			PrintToChatAll("\x04WARNING: %s is \x01black and white \x04with a health of %i.", targetName, health);
		}
	}
	return;
}

/**
 * handle a player getting more health
 *
 * to avoid a lot of noise, only notify survivors when the target's health jumps
 * between brackets (1 = red/low, 2 = yellow/medium, 3=green/high)
 */
public NotifySurvivorsOnHealSuccess(Handle:event, const String:name[], bool:dontBroadcast) {
	if (!enabled) {
		return;
	}
	new target = GetClientOfUserId(GetEventInt(event, "subject"));
	decl String:targetName[64];
	GetClientName(target, targetName, sizeof(targetName));
	int health = GetClientHealth(target);
	/**
	 * make sure the target of the event is a survivor who's in game
	 */
	if (target <= 0 || !IsClientInGame(target) || GetClientTeam(target) != SURVIVOR_TEAM) {
		return;
	}
	int restored = GetEventInt(event, "health_restored");
	int original_health = health - restored;
	if (GetHealthBracket(health) != GetHealthBracket(original_health)) {
		/**
		 * notify survivors on the target's team
		 */
		if (msgType == 1) {
			PrintHintTextToAll("\x03%s's health has increased to %i.", targetName, health);
		} else {
			PrintToChatAll("\x03%s's health has increased to %i.", targetName, health);
		}
	}
	return;
}

/**
 * handle a player taking damage
 *
 * to avoid a lot of noise, only notify survivors when the target's health jumps
 * between brackets (1 = red/low, 2 = yellow/medium, 3=green/high)
 */
public NotifySurvivorsOnPlayerHurt(Handle:event, const String:name[], bool:dontBroadcast) {
	if (!enabled) {
		return;
	}
	new target = GetClientOfUserId(GetEventInt(event, "userid"));
	decl String:targetName[64];
	GetClientName(target, targetName, sizeof(targetName));
	int health = GetClientHealth(target);
	/**
	 * make sure the target of the event is a survivor who's in game
	 */
	if (target <= 0 || !IsClientInGame(target) || GetClientTeam(target) != SURVIVOR_TEAM) {
		return;
	}
	/**
	 * notify survivors on the target's team
	 */
	int damage = GetEventInt(event, "dmg_health");
	int original_health = health + damage;
	if (GetHealthBracket(health) != GetHealthBracket(original_health)) {
		/**
		 * notify survivors on the target's team
		 */
		if (msgType == 1) {
			PrintHintTextToAll("\x04WARNING: %s's health has decreased to %i.", targetName, health);
		} else {
			PrintToChatAll("\x04WARNING: %s's health has decreased to %i.", targetName, health);
		}
		/*for (new x = 1; x <= GetMaxClients(); x++) {
			if (!IsClientInGame(x) || GetClientTeam(x) != GetClientTeam(target) || x == target || IsFakeClient(x)) {
				continue;
			}
			if (msgType == 1) {
				PrintHintText(x, "WARNING: %s's health has decreased to %s.", targetName, health);
			} else {
				PrintToChat(x, "WARNING: %s's health has decreased to %s.", targetName, health);
			}
		}*/
	}
	return;
}

//get cvar changes during game
public ChangeVars(Handle:cvar, const String:oldVal[], const String:newVal[]) {
	//read values from convars
	enabled = GetConVarBool(cvarEnabled);
	msgType = GetConVarInt(cvarMsgType);
}

public int GetHealthBracket(int health) {
	if (health <= HEALTH_LOW) {
		return 1;
	} else if (health <= HEALTH_MED) {
		return 2;
	} else { //health <= HEALTH_HIGH
		return 3;
	}
}


