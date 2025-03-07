local spellRanks = {
    ["Healing Touch"] = { 37, 88, 195, 363, 572, 742, 936, 1199, 1440, 1680 }
}


local function GetTargetHPDev()
    if UnitExists("target") then
        local targetMaxHP = UnitHealthMax("target")
        local randomHPPercentage = math.random(10, 90) / 100 -- Від 10% до 90%
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
    if UnitExists("target") then
        local targetCurrentHP = UnitHealth("target")
        local targetMaxHP = UnitHealthMax("target")
        local targetMissingHP = targetMaxHP - targetCurrentHP
        SmartLogger:PrintInfo("Target HP: " .. targetCurrentHP .. "/" .. targetMaxHP .. " (Missing: " .. targetMissingHP .. ")")
        return targetMissingHP
    else
        SmartLogger:PrintError("No target selected.")
        return nil
    end
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

local myButton = CreateFrame("Button", "MySimpleButton", UIParent, "UIPanelButtonTemplate")
myButton:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
myButton:SetSize(120, 40)
myButton:SetText("Click Me")

myButton:SetScript("OnClick", function()
    local spellName = "Healing Touch"
    local spellRank = GetEffectiveSpellRank(spellName)
    if spellRank then
        SmartLogger:PrintInfo("Casting " .. spellName .. " (Rank " .. spellRank .. ")")
    else
        SmartLogger:PrintError("Failed to determine spell rank.")
    end
end)
