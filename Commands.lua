Commands = {}

SLASH_SSR1 = "/ssr"
SlashCmdList["SSR"] = function(msg)
    local command, arg = strsplit(" ", msg, 2)

    if Commands[command] then
        Commands[command](arg)
    else
        print("|cff00ff00[SmartSpellRank]:|r Використання: /ssr <subcommand>")
    end
end
