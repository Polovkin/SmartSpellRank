local spellRanks = {
    ["Healing Touch"] = { 37, 88, 195, 363, 572, 742, 936, 1199, 1440, 1680, 1890 }
}

local function PrintInfo(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[SmartSpellRank]:|r " .. message)
end

local function PrintError(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[SmartSpellRank]:|r " .. message)
end

local function GetTargetHPDev()
    if UnitExists("target") then
        local targetMaxHP = UnitHealthMax("target")
        local randomHPPercentage = math.random(10, 90) / 100 -- Від 10% до 90%
        local targetCurrentHP = math.floor(targetMaxHP * randomHPPercentage)
        local targetMissingHP = targetMaxHP - targetCurrentHP
        PrintInfo("[DEV MODE] Simulated Target HP: " .. targetCurrentHP .. "/" .. targetMaxHP .. " (Missing: " .. targetMissingHP .. ")")
        return targetMissingHP
    else
        PrintError("No target selected.")
        return nil
    end
end

local function GetTargetHP()
    if UnitExists("target") then
        local targetCurrentHP = UnitHealth("target")
        local targetMaxHP = UnitHealthMax("target")
        local targetMissingHP = targetMaxHP - targetCurrentHP
        PrintInfo("Target HP: " .. targetCurrentHP .. "/" .. targetMaxHP .. " (Missing: " .. targetMissingHP .. ")")
        return targetMissingHP
    else
        PrintError("No target selected.")
        return nil
    end
end

local function GetEffectiveSpellRank(spellName)
    if not spellRanks[spellName] then
        PrintError("Invalid spell name.")
        return
    end

    local targetMissingHP = GetTargetHP()
    if not targetMissingHP then
        PrintError("Unable to determine missing HP.")
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

    PrintInfo("Best rank for " .. spellName .. ": " .. bestRank)

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
        PrintInfo("Casting " .. spellName .. " (Rank " .. spellRank .. ")")
    else
        PrintError("Failed to determine spell rank.")
    end
end)
