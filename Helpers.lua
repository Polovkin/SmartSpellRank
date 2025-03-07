_G.SmartLogger = {}

function SmartLogger:PrintInfo(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[SmartSpellRank]:|r " .. message)
end

function SmartLogger:PrintError(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[SmartSpellRank]:|r " .. message)
end
