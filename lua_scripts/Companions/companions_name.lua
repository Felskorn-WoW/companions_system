local COMPANION_NAME = "Melrania Silversong" --Replace name with desired name
local NPC_ENTRY = 33442 -- Replace with your NPC entry
local SUMMON_COOLDOWN = 30 -- Spell cooldown before you can summon again, in seconds
local SUMMON_SPELL_ID = 42880 -- Replace with custom summoning spell

local summonedNpcs = {}        
local summonCooldowns = {}     
local wasSummonedBeforeFlying = {}
local isCurrentlyFlying = {}
local lastPlayerPosition = {}
local stationaryTime = {}
_G.lastSummonedCompanionEntry = _G.lastSummonedCompanionEntry or {}
local lastSummonedCompanionEntry = _G.lastSummonedCompanionEntry

local function IsValidCreature(creature)
    if not creature then return false end
    local ok = pcall(function() return creature:GetEntry() end)
    return ok
end

local function IsLikelyFlying(player)
    local x, y, z = player:GetLocation()
    local groundZ = player:GetMap():GetHeight(x, y, z)
    if groundZ == z then return false end
    return (z - groundZ) > 2.5
end

local function SummonCompanionForPlayer(player, bypassCooldown)
    local playerGUID = tostring(player:GetGUID())
    local currentTime = os.time()

    if not bypassCooldown and summonCooldowns[playerGUID] and summonCooldowns[playerGUID] > currentTime then
        local remaining = summonCooldowns[playerGUID] - currentTime
        player:SendBroadcastMessage("|cFFFF0000Wait " .. remaining .. " seconds before summoning " .. COMPANION_NAME .. " again!|r")
        return
    end

    local companion = summonedNpcs[playerGUID]
    if not IsValidCreature(companion) then
        local nearby = player:GetCreaturesInRange(100, 0, 0)
        for _, c in ipairs(nearby) do
            if c:GetEntry() == NPC_ENTRY and c:GetOwnerGUID() == player:GetGUID() and c:IsAlive() then
                companion = c
                break
            end
        end
    end

    if IsValidCreature(companion) and companion:IsAlive() then
        player:SendBroadcastMessage("|cFFFF0000" .. COMPANION_NAME .. " is already summoned. Use your dismiss spell first.|r")
        return
    end

    local x, y, z, o = player:GetLocation()
    local offset = 1.5 -- distance near player
    local spawnX = x + math.cos(o + math.pi / 2) * offset
    local spawnY = y + math.sin(o + math.pi / 2) * offset

    companion = player:SpawnCreature(NPC_ENTRY, spawnX, spawnY, z, o, 4, 1440000)

    if companion then  
        companion:SetOwnerGUID(player:GetGUID())
        local playerName = player:GetName()
        local suffix = (playerName:sub(-1):lower() == "s") and "'" or "'s"
        local customSubName = playerName .. suffix .. " Companion"
        companion:SetCustomSubName(customSubName)
        companion:SetFaction(player:GetFaction())
        companion:SetReactState(1)
        companion:SetCustomSubName(customSubName) -- force core trigger (no cache)
        companion:MoveFollow(player, 1.5, math.random() * 2 * math.pi)
                
        if player:IsInCombat() then        
            local selection = player:GetSelection()
            local victim = player:GetVictim()
            local target = selection or victim

            if target then
                local ok, result = pcall(function()
                    return target:IsAlive()
                end)

                if ok and result then
                    companion:SetReactState(1)
                    companion:AttackStart(target)
                    companion:SetInCombatWith(target)
                end
            end
        end

        summonedNpcs[playerGUID] = companion
        lastSummonedCompanionEntry[playerGUID] = NPC_ENTRY
        
        if not bypassCooldown then
            summonCooldowns[playerGUID] = currentTime + SUMMON_COOLDOWN
        end
        
        player:SendBroadcastMessage("|cFF00FF00" .. COMPANION_NAME .. " joins you in your adventures.|r")
    else
        player:SendBroadcastMessage("|cFFFF0000Failed to summon " .. COMPANION_NAME .. ".|r")
    end
end

local function DismissCompanionForPlayer(player, reason)
    local playerGUID = tostring(player:GetGUID())
    local companion = summonedNpcs[playerGUID]

    if not IsValidCreature(companion) then
        local nearby = player:GetCreaturesInRange(100, 0, 0)
        for _, c in ipairs(nearby) do
            if c:GetEntry() == NPC_ENTRY and c:GetOwnerGUID() == player:GetGUID() then
                companion = c
                break
            end
        end
    end

    if not IsValidCreature(companion) then
        if reason ~= "death" and reason ~= "silent" and reason ~= "flying" and reason ~= "distance" then
            player:SendBroadcastMessage("|cFFFF0000" .. COMPANION_NAME .. " is no longer valid or already gone.|r")
        end
        return
    end

    companion:DespawnOrUnsummon(1)

    if reason == "manual" then
        player:SendBroadcastMessage("|cFF00FF00" .. COMPANION_NAME .. " has been dismissed.|r")
    elseif reason == "death" then
        player:SendBroadcastMessage("|cFFFF0000" .. COMPANION_NAME .. " vanishes as you fall in battle.|r")
    elseif reason == "distance" then
        player:SendBroadcastMessage("|cFFFF0000" .. COMPANION_NAME .. " is too far away and vanishes.|r")
    elseif reason == "flying" then
        player:SendBroadcastMessage("|cFFFF0000" .. COMPANION_NAME .. " vanishes as you take to the skies.|r")
    end

    -- Clean up state
    summonedNpcs[playerGUID] = nil

    if reason == "manual" or reason == "death" then
        -- hard reset
        wasSummonedBeforeFlying[playerGUID] = false
        isCurrentlyFlying[playerGUID] = false
        stationaryTime[playerGUID] = 0
        lastPlayerPosition[playerGUID] = nil
        lastSummonedCompanionEntry[playerGUID] = nil
    elseif reason == "flying" or reason == "distance" then
        -- soft reset: allow re-summon later
        wasSummonedBeforeFlying[playerGUID] = true
        isCurrentlyFlying[playerGUID] = true
    end
end

local function OnPlayerLogout(event, player)
    local playerGUID = tostring(player:GetGUID())
    local companion = summonedNpcs[playerGUID]

    if not IsValidCreature(companion) then
        local nearby = player:GetCreaturesInRange(100, 0, 0)
        for _, c in ipairs(nearby) do
            if c:GetEntry() == NPC_ENTRY and c:GetOwnerGUID() == player:GetGUID() then
                companion = c
                break
            end
        end
    end

    if IsValidCreature(companion) then
        companion:DespawnOrUnsummon(1)
    end
    summonedNpcs[playerGUID] = nil
end

local function OnSpellCast(event, player, spell, skipCheck)
    if spell:GetEntry() == SUMMON_SPELL_ID then
        SummonCompanionForPlayer(player, false)
    end
end

local function OnEnterCombat(event, player, enemy)
    local playerGUID = tostring(player:GetGUID())
    local companion = summonedNpcs[playerGUID]

    if not IsValidCreature(companion) then
        local nearby = player:GetCreaturesInRange(100, 0, 0)
        for _, c in ipairs(nearby) do
            if c:GetEntry() == NPC_ENTRY and c:GetOwnerGUID() == player:GetGUID() then
                companion = c
                break
            end
        end
    end

    if not IsValidCreature(companion)
        and wasSummonedBeforeFlying[playerGUID]
        and lastSummonedCompanionEntry[playerGUID] == NPC_ENTRY
    then
        if not player:IsFlying() then
            SummonCompanionForPlayer(player, true)
            wasSummonedBeforeFlying[playerGUID] = false
            isCurrentlyFlying[playerGUID] = false
        end
        return
    end

    if IsValidCreature(companion) and companion:IsAlive() then
        companion:AttackStart(enemy)
    end
end

local function PeriodicFlightCheck(eventId, delay, repeats, player)
    local playerGUID = tostring(player:GetGUID())

    local companion = summonedNpcs[playerGUID]
    if not IsValidCreature(companion) then
        local nearby = player:GetCreaturesInRange(100, 0, 0)
        for _, c in ipairs(nearby) do
            if c:GetEntry() == NPC_ENTRY and c:GetOwnerGUID() == player:GetGUID() and c:IsAlive() then
                companion = c
                break
            end
        end
    end

    if IsValidCreature(companion) then
        local px, py, pz = player:GetLocation()
        local cx, cy, cz = companion:GetLocation()
        local distance = math.sqrt((px - cx)^2 + (py - cy)^2 + (pz - cz)^2)

        if distance > 40 then
            wasSummonedBeforeFlying[playerGUID] = true
            isCurrentlyFlying[playerGUID] = true
            DismissCompanionForPlayer(player, "distance")
            return
        end
    end

    local flying = IsLikelyFlying(player)

    if flying and player:IsFlying() and not isCurrentlyFlying[playerGUID] then
        isCurrentlyFlying[playerGUID] = true
        if summonedNpcs[playerGUID] then
            wasSummonedBeforeFlying[playerGUID] = true
            DismissCompanionForPlayer(player, "flying")
        end
        return
    end

    if not flying and not player:IsFlying() and isCurrentlyFlying[playerGUID] then
        local px, py, pz = player:GetLocation()
        local lastPos = lastPlayerPosition[playerGUID]
        local moved = true

        if lastPos then
            local dx = px - lastPos[1]
            local dy = py - lastPos[2]
            local dz = pz - lastPos[3]
            local movement = math.sqrt(dx * dx + dy * dy + dz * dz)
            moved = movement > 0.5
        end

        lastPlayerPosition[playerGUID] = { px, py, pz }

        if not moved then
            stationaryTime[playerGUID] = (stationaryTime[playerGUID] or 0) + 1

            if stationaryTime[playerGUID] >= 1 then
                isCurrentlyFlying[playerGUID] = false

                if wasSummonedBeforeFlying[playerGUID] then
                    local nearby = player:GetCreaturesInRange(100, 0, 0)
                    local alreadyActive = false
                    for _, c in ipairs(nearby) do
                        if c:GetEntry() ~= NPC_ENTRY and c:GetOwnerGUID() == player:GetGUID() and c:IsAlive() then
                            alreadyActive = true
                            break
                        end
                    end

                    if not alreadyActive and lastSummonedCompanionEntry[playerGUID] == NPC_ENTRY then
                        SummonCompanionForPlayer(player, true)
                        wasSummonedBeforeFlying[playerGUID] = false
                    end
                end

                stationaryTime[playerGUID] = 0
            end
        else
            stationaryTime[playerGUID] = 0
        end
    end
end

local function OnSummon(event, player, spell, skipCheck)
    if spell:GetEntry() == SUMMON_SPELL_ID then
        player:RegisterEvent(PeriodicFlightCheck, 1000, 0)
    end
end

local function PlayerDeath(event, killer, player)
    DismissCompanionForPlayer(player, "death")
end

local function OnAreaUpdate(event, player)
    local creatures = player:GetCreaturesInRange(100, 0, 0)

    for _, creature in ipairs(creatures) do
        local entry = creature:GetEntry()
        local ownerGUID = creature:GetOwnerGUID()
        local subname = creature:GetCustomSubName()

        if entry == NPC_ENTRY and subname and subname ~= "" and ownerGUID ~= player:GetGUID() then
            creature:SetCustomSubName(subname)
        end
    end
end

local function OnLogin(event, player)
    local creatures = player:GetCreaturesInRange(100, 0, 0)

    for _, creature in ipairs(creatures) do
        local entry = creature:GetEntry()
        local ownerGUID = creature:GetOwnerGUID()
        local subname = creature:GetCustomSubName()

        if entry == NPC_ENTRY and subname and subname ~= "" and ownerGUID ~= player:GetGUID() then
            creature:SetCustomSubName(subname)
        end
    end
end

RegisterPlayerEvent(3, OnLogin)
RegisterPlayerEvent(27, OnAreaUpdate)
RegisterPlayerEvent(4, OnPlayerLogout)
RegisterPlayerEvent(5, OnSpellCast)
RegisterPlayerEvent(5, OnSummon)
RegisterPlayerEvent(8, PlayerDeath)
RegisterPlayerEvent(33, OnEnterCombat)
