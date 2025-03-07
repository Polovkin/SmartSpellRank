local spellRanks = {
    ["Healing Touch"] = { 47.5, 104.5, 225.5, 413.5, 641.5, 803.5, 1012.5, 1400.5, 2000.5, 2200 }
}


local function GetTargetHPDev()
    if UnitExists("target") then
        local targetMaxHP = UnitHealthMax("target")
        local randomHPPercentage = math.random(90, 98) / 100
        local targetCurrentHP = math.floor(targetMaxHP * randomHPPercentage)
        local targetMissingHP = targetMaxHP - targetCurrentHP
        SmartLogger:PrintInfo("[DEV MODE] Simulated Target HP: " .. targetCurrentHP .. "/" .. targetMaxHP .. " (Missing: " .. targetMissingHP .. ")")
        return targetMissingHP
    else
        SmartLogger:PrintError("No target selected.")
        return nil
    end
end

local function GetTargetHP()
    if not UnitExists("target") then
        SmartLogger:PrintError("No target selected.")
        return nil
    end

    if not UnitIsFriend("player", "target") then
        SmartLogger:PrintError("Target is not a friendly unit.")
        return nil
    end

    local targetCurrentHP = UnitHealth("target")
    local targetMaxHP = UnitHealthMax("target")
    local targetMissingHP = targetMaxHP - targetCurrentHP
    SmartLogger:PrintInfo("Target HP: " .. targetCurrentHP .. "/" .. targetMaxHP .. " (Missing: " .. targetMissingHP .. ")")

    return targetMissingHP
end

local function GetEffectiveSpellRank(spellName)
    if not spellRanks[spellName] then
        SmartLogger:PrintError("Invalid spell name.")
        return
    end

    local targetMissingHP = GetTargetHPDev()

    if not targetMissingHP then
        SmartLogger:PrintError("Unable to determine missing HP.")
        return
    end

    local bestRank = 1
    local maxRank = #spellRanks[spellName]

    if targetMissingHP > 0 then
        for rank, healAmount in ipairs(spellRanks[spellName]) do
            if healAmount >= targetMissingHP then
                bestRank = rank
                break
            end
        end
    end

    if bestRank == 1 and spellRanks[spellName][maxRank] < targetMissingHP then
        bestRank = maxRank
    end

    SmartLogger:PrintInfo("Best rank for " .. spellName .. ": " .. bestRank)

    return bestRank
end


local function CreateHealButton(parent, unit)
    if not parent then
        SmartLogger:PrintError("No parent frame for " .. unit)
        return nil
    end

    local btn = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate")
    btn:SetAttribute("type", "spell")

    btn:SetSize(60, 25)
    btn:SetPoint("TOP", parent, "BOTTOM", 0, -5)

    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(btn)
    bg:SetColorTexture(0, 0, 0, 0.5)

    local text = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    text:SetPoint("CENTER", btn, "CENTER", 0, 0)
    text:SetText("Heal")

    btn:SetScript("PreClick", function(self)
        if not UnitExists(unit) then
            SmartLogger:PrintError("No valid target for " .. unit)
            self:SetAttribute("spell", nil)
            return
        end

        local spellName = "Healing Touch"
        local spellRank = GetEffectiveSpellRank(spellName)

        if spellRank then
            self:SetAttribute("spell", spellName .. "(Rank " .. spellRank .. ")")
            self:SetAttribute("unit", unit)
            SmartLogger:PrintInfo("Healing " .. UnitName(unit) .. " with " .. spellName .. " (Rank " .. spellRank .. ")")
        else
            SmartLogger:PrintError("Failed to determine spell rank.")
            self:SetAttribute("spell", nil)
        end
    end)

    btn:Show()
    return btn
end

for i = 1, 4 do
    local partyFrame = _G["PartyMemberFrame" .. i] or _G["CompactPartyFrameMember" .. i]
    if partyFrame then
        SmartLogger:PrintInfo("Creating button for " .. "party" .. i)
        local healButton = CreateHealButton(partyFrame, "party" .. i)
    else
        SmartLogger:PrintError("Party frame " .. i .. " not found")
    end
end
