--------------------------------
------- Created by Hamza -------
-------------------------------- 

local ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Server Event for Buying:
RegisterServerEvent("xlp-pawnshop:BuyItem")
AddEventHandler("xlp-pawnshop:BuyItem", function(amountToBuy,totalBuyPrice,itemName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local itemLabel = ESX.GetItemLabel(itemName)
	if xPlayer.getMoney() >= totalBuyPrice then
		xPlayer.removeMoney(totalBuyPrice)
		xPlayer.addInventoryItem(itemName, amountToBuy)
		TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = "Pagaste "..totalBuyPrice.." € por "..amountToBuy.."x "..itemLabel.."", length = 4000})
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = "Dinheiro insuficiente", length = 4000})
	end
end)

-- Server Event for Selling:
RegisterServerEvent("xlp-pawnshop:SellItem")
AddEventHandler("xlp-pawnshop:SellItem", function(amountToSell,totalSellPrice,itemName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local itemLabel = ESX.GetItemLabel(itemName)
	if xPlayer.getInventoryItem(itemName).count >= amountToSell then
		xPlayer.addMoney(totalSellPrice)
		xPlayer.removeInventoryItem(itemName, amountToSell)
		TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = "Vendeste "..amountToSell.."x "..itemLabel.." por "..totalSellPrice.." €", length = 4000})
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'success', text = "Items insuficientes", length = 4000})
	end
end)
