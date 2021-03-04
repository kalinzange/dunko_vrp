--(Thanks to Rubbertoe98) (https://github.com/rubbertoe98/FiveM-Scripts/tree/master/vrp_punishments) for the original script.
-- Edits by JamesUK#6793 (to support js ghmatti version)

AddEventHandler('chatMessage', function(player, color, message)
	user_id = vRP.getUserId(player)
    if message:sub(1, 13) == '/showwarnings' then
		local permID =  tonumber(message:sub(14, 20))
		if permID ~= nil then
			if vRP.hasPermission(permID,"player.kick") then
				vrpwarningstables = getvrpWarnings(permID,player)
				TriggerClientEvent("vrp:showWarningsOfUser",player,vrpwarningstables)
			end
		end
    end
	CancelEvent()
end)


	
function getvrpWarnings(user_id,source) 
	vrpwarningstables = exports['ghmattimysql']:executeSync("SELECT * FROM vrp_warnings WHERE user_id = @uid", {uid = user_id})
	for warningID,warningTable in pairs(vrpwarningstables) do
		date = warningTable["warning_date"]
		newdate = tonumber(date) / 1000
		newdate = os.date('%Y-%m-%d', newdate)
		warningTable["warning_date"] = newdate
        warningTable["warning_id"] = warningID
	end
	return vrpwarningstables
end

RegisterServerEvent("vrp:refreshWarningSystem")
AddEventHandler("vrp:refreshWarningSystem",function()
	local source = source
	local user_id = vRP.getUserId(source)	
	vrpwarningstables = getvrpWarnings(user_id,source)
	TriggerClientEvent("vrp:recievedRefreshedWarningData",source,vrpwarningstables)
end)

RegisterServerEvent("vrp:warnPlayer")
AddEventHandler("vrp:warnPlayer",function(target_id,adminName,warningReason)
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"player.kick") then
		warning = "Warning"
		warningDate = getCurrentDate()
		exports['ghmattimysql']:execute("INSERT INTO vrp_warnings (`user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`) VALUES (@user_id, @warning_type, 0, @admin, @warning_date,@reason);", {user_id = target_id,warning_type = warning, admin = adminName, warning_date = warningDate, reason = warningReason}, function() end)
	else
		vRPclient.notify(player,{"~r~no perms to warn player"})
	end
end)

function saveWarnLog(target_id,adminName,warningReason)
	warning = "Warning"
	warningDate = getCurrentDate()
	exports['ghmattimysql']:execute("INSERT INTO vrp_warnings (`user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`) VALUES (@user_id, @warning_type, 0, @admin, @warning_date,@reason);", {user_id = target_id,warning_type = warning, admin = adminName, warning_date = warningDate, reason = warningReason}, function() end)
end

function saveKickLog(target_id,adminName,warningReason)
	warning = "Kick"
	warningDate = getCurrentDate()
	exports['ghmattimysql']:execute("INSERT INTO vrp_warnings (`user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`) VALUES (@user_id, @warning_type, 0, @admin, @warning_date,@reason);", {user_id = target_id,warning_type = warning, admin = adminName, warning_date = warningDate, reason = warningReason}, function() end)
end

function saveBanLog(target_id,adminName,warningReason,warning_duration)
	warning = "Ban"
	warningDate = getCurrentDate()
	exports['ghmattimysql']:execute("INSERT INTO vrp_warnings (`user_id`, `warning_type`, `duration`, `admin`, `warning_date`, `reason`) VALUES (@user_id, @warning_type, @duration, @admin, @warning_date,@reason);", {user_id = target_id,warning_type = warning, admin = adminName, duration = warning_duration, warning_date = warningDate, reason = warningReason}, function() end)
end


function getCurrentDate()
	date = os.date("%Y/%m/%d")
	return date
end
