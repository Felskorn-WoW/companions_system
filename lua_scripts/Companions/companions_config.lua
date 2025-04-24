local DISMISS_SPELL_ID = 42880 -- Replace this with a custom dismiss spell

-- SpellID -> NPC_ENTRY mapping
local COMPANION_SPELLS = {
    [42880] = 33442, -- Replace with your own summon spell id and npc id
--    [SPELLIDHERE] = NPCIDHERE, Add new entries for every new companion
}

local VALID_COMPANION_ENTRIES = {}
for _, npcEntry in pairs(COMPANION_SPELLS) do
    VALID_COMPANION_ENTRIES[npcEntry] = true
end

local function OnDismissSpellCast(event, caster, spell, skipCheck)
    if spell:GetEntry() ~= DISMISS_SPELL_ID then return end

    local nearby = caster:GetCreaturesInRange(100, 0, 0)
    local dismissed = 0

    for _, creature in ipairs(nearby) do
        if VALID_COMPANION_ENTRIES[creature:GetEntry()] and creature:GetOwnerGUID() == caster:GetGUID() then
            creature:DespawnOrUnsummon(1)
            dismissed = dismissed + 1
        end
    end

    if dismissed > 0 then
        local guid = tostring(caster:GetGUID())
        for _, fileFlag in ipairs({
            "wasSummonedBeforeFlying",
            "isCurrentlyFlying",
            "stationaryTime",
            "lastPlayerPosition",
            "lastSummonedCompanionEntry"
        }) do
            _G[fileFlag] = _G[fileFlag] or {}
            _G[fileFlag][guid] = nil
        end

        caster:SendBroadcastMessage("|cFF00FF00Your companion has been dismissed.|r")
    else
        caster:SendBroadcastMessage("|cFFFF0000You have no companion to dismiss.|r")
    end
end

local function CleanupExtraCompanions(player)
    local count = 0
    local toRemove = {}

    local nearby = player:GetCreaturesInRange(100, 0, 0)
    for _, creature in ipairs(nearby) do
        if VALID_COMPANION_ENTRIES[creature:GetEntry()]
            and creature:GetOwnerGUID() == player:GetGUID()
            and creature:IsAlive() then

            count = count + 1
            if count > 1 then
                table.insert(toRemove, creature)
            end
        end
    end

    if #toRemove > 0 then
        for _, creature in ipairs(toRemove) do
            player:SendBroadcastMessage("|cFFFF0000You can only have one companion active.|r")
            creature:DespawnOrUnsummon(1)
        end
    end
end

local function OnCompanionSpellCast(event, player, spell, skipCheck)
    local spellId = spell:GetEntry()
    if not COMPANION_SPELLS[spellId] then return end

    -- Delay
    player:RegisterEvent(function(_, _, _, p)
        CleanupExtraCompanions(p)
    end, 50, 1)
end

RegisterPlayerEvent(5, OnCompanionSpellCast)
RegisterPlayerEvent(5, OnDismissSpellCast)
