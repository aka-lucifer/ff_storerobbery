---@param source integer
---@param message string
---@param type 'inform' | 'error' | 'success' | 'warning'
---@param time? integer
---@param icon? string
function Notify(source, message, type, time, icon)
    TriggerClientEvent("ff_shoprobbery:client:notify", source, message, type, time, icon)
end

---@param source integer Player ID
---@param amount integer How much money to give
---@param reason string What the money was for
function GiveMoney(source, amount, reason)
    if Config.UseMoneyItem then
        if Config.Framework == "Qbox" or Config.Framework == "QB" then
            GiveItem(source, "markedbills", 1, {
                worth = amount
            })
        elseif Config.Framework == "Mythic" then
            GiveItem(source, "moneyroll", math.floor(amount / 100))
        elseif Config.Framework == "ESX" then
            Error("ESX doesn't support giving money as items by default!")
        end
    else
        if not reason then reason = "ff_shoprobbery" end
        AddMoney(source, amount, "cash", reason)
    end
end

---@param source integer
---@param username string
---@param identifier string
---@param title string
---@param message string
---@param colour? integer
function SendWebhook(source, username, identifier, title, message, colour)
    if not colour then colour = Colours.Default end

    local embed = {
        {
            title = title,
            description = string.format(
                "**Source**: %s\n**Username**: %s\n**Identifier**: %s\n**Message**: %s",
                source,
                username,
                identifier,
                message
            ),
            color = colour,
            footer = {
                text = os.date("%a %b %d, %I:%M%p", os.time()),
                icon_url = "https://r2.fivemanage.com/19ENzTzshMEbKsIoRJRJp/images/fiveforge_avatar.png"
            },
        }
    }

    PerformHttpRequest(SvConfig.Webhook, function(err, text, headers) end, 'POST', json.encode(
        {
            username = GetCurrentResourceName(),
            avatar_url = "https://r2.fivemanage.com/19ENzTzshMEbKsIoRJRJp/images/fiveforge_avatar.png",
            embeds = embed
        }
    ), { ['Content-Type'] = 'application/json' })
end
