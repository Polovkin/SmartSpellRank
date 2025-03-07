local spellRanks = {
    ["Healing Touch"] = {37, 88, 195, 363, 572, 742, 936, 1199, 1440, 1680, 1890},
    ["Regrowth"] = {150, 300, 450, 600, 750, 900, 1050, 1200, 1350},
    ["Rejuvenation"] = {50, 100, 175, 245, 315, 400, 490, 600, 750, 900}
}

local myButton = CreateFrame("Button", "MySecureButton", UIParent, "SecureActionButtonTemplate")
myButton:SetAttribute("type", "macro")  -- Тип дії: макрос
myButton:SetPoint("CENTER", UIParent, "CENTER", 0, -50) -- Центр екрана
myButton:SetSize(100, 40) -- Ширина 100, висота 40

-- Робимо кнопку видимою
myButton:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
myButton:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
myButton:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")

local function GetTargetHP()
    if UnitExists("target") then
        local targetCurrentHP = UnitHealth("target")
        local targetMaxHP = UnitHealthMax("target")
        local targetMissingHP = targetMaxHP - targetCurrentHP
        print("|cff00ff00[SmartSpellRank]:|r Target HP: " .. targetCurrentHP .. "/" .. targetMaxHP .. " (Missing: " .. targetMissingHP .. ")")
        return targetMissingHP
    else
        print("|cffff0000[SmartSpellRank]:|r No target selected.")
        return nil
    end
end

local function UpdateMacro(spellName)
    if not spellRanks[spellName] then
        print("|cffff0000[SmartSpellRank]:|r Invalid spell name.")
        return
    end

    local targetMissingHP = GetTargetHP()
    if not targetMissingHP then
        print("|cffff0000[SmartSpellRank]:|r Unable to determine missing HP.")
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

    print("|cff00ff00[SmartSpellRank]:|r Best rank for " .. spellName .. ": " .. bestRank)

    local macroText = "/cast [@target,help,nodead] " .. spellName .. "(Rank " .. bestRank .. ")"
    myButton:SetAttribute("macrotext", macroText) -- Оновлюємо макрос
end

Commands["heal"] = function(spellName)
    if spellName then
        UpdateMacro(spellName)
    else
        print("|cff00ff00[SmartSpellRank]:|r Usage: /ssr heal <spell_name>")
    end
end

myButton:SetScript("OnMouseDown", function(self, button)
    if button == "LeftButton" then
        print("|cff00ff00[SmartSpellRank]:|r Button pressed: " .. button)
        UpdateMacro("Healing Touch")
    end
end)

myButton:SetScript("OnMouseUp", function(self, button)
    if button == "LeftButton" then
        print("|cff00ff00[SmartSpellRank]:|r Casting spell...")
        myButton:Click()
    end
end)
