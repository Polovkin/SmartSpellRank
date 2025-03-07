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

    --[[local targetMissingHP = GetTargetHP()]]
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


local healButton = CreateFrame("Button", "HealSpellButton", UIParent, "SecureActionButtonTemplate")
healButton:SetAttribute("type", "spell")
healButton:SetAttribute("spell", "Healing Touch(Rank 1)") -- Початкове значення
healButton:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
healButton:SetSize(120, 40)

-- Додаємо фон через текстуру
local bg = healButton:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(healButton)
bg:SetColorTexture(0, 0, 0, 0.5) -- Чорний фон з прозорістю

local buttonText = healButton:CreateFontString(nil, "ARTWORK", "GameFontNormal")
buttonText:SetPoint("CENTER", healButton, "CENTER", 0, 0)
buttonText:SetText("Heal")
healButton:SetFontString(buttonText)

healButton:SetScript("PreClick", function(self)
    local spellName = "Healing Touch"
    local spellRank = GetEffectiveSpellRank(spellName)

    if spellRank then
        self:SetAttribute("spell", spellName .. "(Rank " .. spellRank .. ")")
        SmartLogger:PrintInfo("Setting up: " .. spellName .. " (Rank " .. spellRank .. ")")
    else
        SmartLogger:PrintError("Failed to determine spell rank.")
    end
end)

healButton:Show()

