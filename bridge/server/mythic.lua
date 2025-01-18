if Config.Framework ~= "Mythic" then return end

local function retrieveComponents()
	Database = exports["mythic-base"]:FetchComponent("Database")
	Logger = exports["mythic-base"]:FetchComponent("Logger")
	Fetch = exports["mythic-base"]:FetchComponent("Fetch")
	Inventory = exports["mythic-base"]:FetchComponent("Inventory")
	Wallet = exports["mythic-base"]:FetchComponent("Wallet")
	Banking = exports["mythic-base"]:FetchComponent("Banking")
	Execute = exports["mythic-base"]:FetchComponent("Execute")
	Jobs = exports["mythic-base"]:FetchComponent("Jobs")
	Crypto = exports["mythic-base"]:FetchComponent("Crypto")
	Vehicles = exports["mythic-base"]:FetchComponent("Vehicles")
end

AddEventHandler("ff_shoprobbery:Shared:DependencyUpdate", retrieveComponents)

AddEventHandler("Core:Shared:Ready", function()
	exports["mythic-base"]:RequestDependencies("ff_shoprobbery", {
		"Database",
		"Logger",
		"Fetch",
		"Inventory",
		"Wallet",
		"Banking",
		"Execute",
		"Jobs",
		"Crypto",
		"Vehicles"
	}, function(error)
		if #error > 0 then
			Logger:Critical("ff_shoprobbery, "Failed To Load All Dependencies")
			return
		end

		retrieveComponents()
	end)
end)

---@param source number
---@return boolean
function IsAdmin(source)
    return Fetch:Source(source).Permissions:IsAdmin()
end

---@param source number
---@param item string
---@param amount? number
---@return boolean
function HasItem(source, item, amount)
    if not amount then amount = 1 end

	local char = Fetch:Source(source):GetData("Character")
	local count = Inventory.Items:GetCount(char:GetData("SID"), 1, item)

    if count < amount then
		Debug(("Not enough of %s in inventory"):format(item), DebugTypes.Info)
        return false
    end
    
    return true
end

---@param source number
---@param item string
---@param amount? number
---@return boolean
function GiveItem(source, item, amount)
    if not amount then amount = 1 end
	local char = Fetch:Source(source):GetData("Character")
	return Inventory:AddItem(char:GetData("SID"), item, amount, {}, 1)
end

---@param source number
---@param item string
---@param amount? number
---@return boolean
function RemoveItem(source, item, amount)
    if not amount then amount = 1 end
	local char = Fetch:Source(source):GetData("Character")
	return Inventory.Items:Remove(char:GetData("SID"), 1, item, amount)
end

---@param item string
---@param itemUse function
function CreateUsableItem(item, itemUse)
	Inventory.Items:RegisterUse(item, "ff_dealerheist", function(source, item)
		itemUse(source, item)
	end)
end

---@param source number
---@return table
function GetPlayer(source)
	return Fetch:Source(source)
end

---@param source number
---@param amount number
---@param account "cash" | "bank" | "money"
---@param transactionData? { title: string, description: string }
function AddMoney(source, amount, account, transactionData)
	if account == "money" then account = "cash" end
    local player = GetPlayer(source)
    
	if account == "cash" then
        Wallet:Modify(source, math.ceil(amount))
    elseif account == "bank" then
        local char = player:GetData("Character")
        local account = Banking.Accounts:GetPersonal(char:GetData("SID"))?.Balance
        Banking.Balance:Withdraw(account, amount, {
            type = "withdraw",
            title = transactionData and transactionData.title or "Store Robbery",
            description = transactionData and transactionData.description or "Robbed a store.",
            transactionAccount = false,
            data = {
                character = char:GetData("SID"),
            },
        })
    end
end

---@return number
function GetPoliceCount()
	return GlobalState["Duty:police"] or 0
end

---@return number[]
function GetPolice()
	local players = {}
	for _, player in pairs(Fetch:All()) do
		local src = player:GetData("Source")
		if Jobs.Permissions:HasJob(src, 'police') and Player(src).state.onDuty == 'police' then
			players[#players + 1] = src
		end
	end

	return players
end

---@param source integer
---@return boolean
function CanReset(source)
    local player = Fetch:Source(source)
    if not player then return false end

	for jobId, requiredGrade in pairs(Config.ResetAccess.Jobs) do
		local job = Jobs.Permissions:HasJob(jobId)
		if job and job.Grade.Level >= requiredGrade then
			return true
		end
	end
    
	if player.Permissions:IsAdmin() then
		return true
	end

    return false
end

---@param source number
---@param username string
---@param title string
---@param message string
---@param colour? number
function SendLog(source, username, title, message, colour)
    local player = Fetch:Source(source)
    if not player then return false end
    SendWebhook(source, username, player:GetData("Character"):GetData("SID"), title, message, colour)
end
