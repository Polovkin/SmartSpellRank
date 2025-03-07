local frame = CreateFrame("Frame")
local addonName = "SmartSpellRank"
local helloMessage = "|cff00ff00Hello, World! Your addon is working in WoW 1.15.6!|r"

frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, ...)
    print(helloMessage + addonName)
end)
