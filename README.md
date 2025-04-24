# companions_system

This is a Eluna script designed to simulate having personal companions to assist players in combat(Server Side) and not requiring core side or mass DBC edits. This system will do the following.
- Summoned NPC using a spell. Customizable for custom dummy summoning spells.
- Dismiss NPC using a spell. Customizable for custom dummy dismiss spell.
- Summoned NPC will only attack what the player does.
- Summoned NPC will vanish when it gets a certain distance away from the player. Customiable.
- Summoned NPC will vanish and reapear when the player mounts and dismounts.
- Dismissing will only affect the companions and not dismiss a Warlock, Hunter, or Death Knight Pet.
- Summoned NPC will use server-side setting to handle it's abilities. SmartAI, Eluna, and Core-side scripts.
- Summoned NPC are entirely controlled from creature_template. This includes level, health, mana, speed, and damage.
- Limits the player to only have one companion out a time.

Suggested Tips
- Use faction 1718 for companions. Will ensure they do not killsteal loot and are friendly to ALL players.
- Keep in mind this simulates summoning a pet and only summons a creature. So design your companions with that in mind!
- It's best to create your own spells for Summoning and dismissing companions. These spells should be DUMMY spells and only use is for the visual name and description text! This will however work with ANY spell you set.
- This system is mainly for PvE use and is not suggested for PvP as NPCs do not follow the same rules as a player does in PvP.
- Highly suggest adding basic spells to the companions using SAI, its very easy to adjust them for balancing.

Credits
- Hawjiki for basic script, planning and idea.
- ChatGPT for assisting me with some aspects.
- Fenuks for overhauling, improvements, and generally making it work and run smoothly. <3
