# companions_system
![banner](https://github.com/Felskorn-WoW/companions_system/blob/main/baner.png?raw=true)

This is a Eluna script designed to simulate having personal companions to assist players in combat(Server Side) and not requiring core side or a lot DBC edits. This system will do the following.
- Summons NPC using a spell. Customizable.
- Dismiss NPC using a spell. Customizable.
- Summoned NPC will only attack what the player does.
- Summoned NPC will vanish when it gets a certain distance away from the player. Customizable.
- Summoned NPC will vanish and reappear when the player mounts and dismounts.
- Dismissing will only affect the companions and not dismiss a Warlock, Hunter, or Death Knight Pet.
- Summoned NPC will use server-side settings to handle it's abilities. SmartAI, Eluna, and Core-side scripts.
- Summoned NPC are entirely controlled from creature_template. This includes level, health, mana, speed, and damage.
- Limits the player to only have one companion out a time.


**Adding New Companions**
- Copy the companions_name.lua
- Rename companions_*name*.lua to whatever your new companion name is.
- Fill in the correct name, summon spell id, and npc entry.
- Open companions_config
- Add a new line at local COMPANION_SPELLS with your new companion info
- Reload or restart and enjoy.

**Suggested Tips**
- Use faction 1718 for companions. Will ensure they do not killsteal loot and are friendly to ALL players.
- Keep in mind this simulates summoning a pet and only summons a creature. So design your companions with that in mind!
- It's best to create your own spells for Summoning and dismissing companions. These spells should be DUMMY spells and only uses are the visual name and description text! This will however work with ANY spell you set.
- This system is mainly for PvE useage and is not suggested for PvP as NPCs do not follow the same rules as a player does in PvP. You would have to add the summoning spells to the disable table to prevent use in BG/Arena.
- Highly suggest adding basic spells to the companions using SAI, its very easy to adjust them for balancing.

**Credits**
- Hawjiki for basic script, planning and idea.
- Fenuks for overhauling, improvements, and generally making it work and run smoothly. <3

**Notes**
This script was designed for use Felskorn WoW and as such, it's future development will be with this server's plans.

[![Preview](http://i3.ytimg.com/vi/P9zsLL2xS10/hqdefault.jpg)](https://www.youtube.com/watch?v=P9zsLL2xS10)
