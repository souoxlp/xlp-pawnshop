--------------------------------
------- Created by Hamza -------
-------------------------------- 

ESX = nil
local insideMarker = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	PlayerData = ESX.GetPlayerData()
end)

-- Core Thread Function:
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		local coords = GetEntityCoords(PlayerPedId())
		for k,v in pairs(Config.PawnZones) do
			for i = 1, #v.Pos, 1 do
				local distance = Vdist(coords, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z)
				if (distance < 7.0) and insideMarker == false then
				end
				if (distance < 1.0) and insideMarker == false then
					DrawText3Ds(v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, Config.ShopDraw3DText)
					if IsControlJustPressed(0, Config.KeyToOpenShop) then
						exports['mythic_progbar']:Progress({
							name = "carlock",
							duration = 5000,
							label = 'A negociar...',
							useWhileDead = false,
							canCancel = true,
							controlDisables = {
								disableMovement = true,
								disableCarMovement = true,
								disableMouse = false,
								disableCombat = true,
							},
							animation = {
								animDict = "random@countrysiderobbery",
								anim = "idle_a",
								flags = 49,
							}
						}, function(cancelled)
							if not cancelled then
						     PawnShopMenu()
						     insideMarker = true
						     Citizen.Wait(500)
						    end
						end) 
					
					end
				
				end
			
			end
		
		end
	
	end

end)

-- Function for Pawn Shop Main Menu:
PawnShopMenu = function()
	local player = PlayerPedId()
	FreezeEntityPosition(player,true)
	
	local elements = {
		{ label = "Comprar", action = "PawnShop_Buy_Menu" },
		{ label = "Vender", action = "PawnShop_Sell_Menu" },
	}
		
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "erp_pawnshop_main_menu",
		{
			title    = "Penhores",
			align    = "right",
			elements = elements
		},
	function(data, menu)
		local action = data.current.action

		if action == "PawnShop_Buy_Menu" then
			PawnShopBuyMenu()
		elseif action == "PawnShop_Sell_Menu" then
			PawnShopSellMenu()
		end	
	end, function(data, menu)
		menu.close()
		insideMarker = false
		FreezeEntityPosition(player,false)
	end, function(data, menu)
	end)
end

-- Function for Pawn Shop Buy Menu:
function PawnShopBuyMenu()
	local player = PlayerPedId()
	FreezeEntityPosition(player,true)
	local elements = {}
			
	for k,v in pairs(Config.ItemsInPawnShop) do
		if v.BuyInPawnShop == true then
			table.insert(elements,{label = v.label .. " | "..('<span style="color:green;">%s</span>'):format("$"..v.BuyPrice..""), itemName = v.itemName, BuyInPawnShop = v.BuyInPawnShop, BuyPrice = v.BuyPrice})
		end
	end
		
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "xlp_pawnshop_buy_menu",
		{
			title    = "O que queres comprar?",
			align    = "right",
			elements = elements
		},
	function(data, menu)
			if data.current.itemName == data.current.itemName then
				OpenBuyDialogMenu(data.current.itemName,data.current.BuyPrice)
			end	
	end, function(data, menu)
		menu.close()
		insideMarker = false
		FreezeEntityPosition(player,false)
	end, function(data, menu)
	end)
end

-- Function for Pawn Shop Buy Dialog
function OpenBuyDialogMenu(itemName, BuyPrice)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'xlp_pawnshop_amount_to_buy_dialog', {
		title = "Quantidade?"
	}, function(data, menu)
		menu.close()
		amountToBuy = tonumber(data.value)
		totalBuyPrice = (BuyPrice * amountToBuy)
		TriggerServerEvent("xlp-pawnshop:BuyItem",amountToBuy,totalBuyPrice,itemName)
	end,
	function(data, menu)
		menu.close()	
	end)
end

-- Function for Pawn Shop Sell Menu:
function PawnShopSellMenu()
	local player = PlayerPedId()
	FreezeEntityPosition(player,true)
	local elements = {}
			
	for k,v in pairs(Config.ItemsInPawnShop) do
		if v.SellInPawnShop == true then
			table.insert(elements,{label = v.label .. " | "..('<span style="color:green;">%s</span>'):format("$"..v.SellPrice..""), itemName = v.itemName, SellInPawnShop = v.SellInPawnShop, SellPrice = v.SellPrice})
		end
	end
		
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), "xlp_pawnshop_sell_menu",
		{
			title    = "O que queres vender?",
			align    = "right",
			elements = elements
		},
	function(data, menu)
			if data.current.itemName == data.current.itemName then
				OpenSellDialogMenu(data.current.itemName,data.current.SellPrice)
			end	
	end, function(data, menu)
		menu.close()
		insideMarker = false
		FreezeEntityPosition(player,false)
	end, function(data, menu)
	end)
end

-- Function for Pawn Shop Sell Dialog
function OpenSellDialogMenu(itemName, SellPrice)
	ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'xlp_pawnshop_amount_to_sell_dialog', {
		title = "Quantidade?"
	}, function(data, menu)
		menu.close()
		amountToSell = tonumber(data.value)
		totalSellPrice = (SellPrice * amountToSell)
		TriggerServerEvent("xlp-pawnshop:SellItem",amountToSell,totalSellPrice,itemName)
	end,
	function(data, menu)
		menu.close()	
	end)
end

-- Blip on Map for Pawn Shops:
Citizen.CreateThread(function()
	if Config.EnablePawnShopBlip == true then	
		for k,v in pairs(Config.PawnZones) do
			for i = 1, #v.Pos, 1 do
				local blip = AddBlipForCoord(v.Pos[i].x, v.Pos[i].y, v.Pos[i].z)
				SetBlipSprite(blip, Config.BlipSprite)
				SetBlipDisplay(blip, Config.BlipDisplay)
				SetBlipScale  (blip, Config.BlipScale)
				SetBlipColour (blip, Config.BlipColour)
				SetBlipAsShortRange(blip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(Config.BlipName)
				EndTextCommandSetBlipName(blip)
			end
		end
	end	
end)

-- Function for 3D text:
function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
  
	local scale = 0.32
   
	if onScreen then
		SetTextScale(scale, scale)
		SetTextFont(4)
		SetTextProportional(1)
		SetTextColour(255, 255, 255, 215)
		SetTextOutline()
		SetTextEntry("STRING")
		SetTextCentre(1)
		AddTextComponentString(text)
        DrawText(_x,_y)
        local factor = (string.len(text)) / 500
        DrawRect(_x,_y+0.0125, 0.015+ factor , 0.030, 1, 0, 0, 150)
	end
end

--------
--NPC
--------
local pedlist = {
    { ['x'] = -1459.33 , ['y'] = -413.64 , ['z'] = 35.75, ['h'] = 163.34, ['hash'] = 0x2DADF4AA, ['hash2'] = "a_m_y_downtown_01" },
   }
   
   CreateThread(function()
    for k,v in pairs(pedlist) do
     RequestModel(GetHashKey(v.hash2))
     while not HasModelLoaded(GetHashKey(v.hash2)) do Wait(100) end
     ped = CreatePed(4,v.hash,v.x,v.y,v.z-1,v.h,false,true)
     peds = ped
     FreezeEntityPosition(ped,true)
     SetEntityInvincible(ped,true)
     SetBlockingOfNonTemporaryEvents(ped,true)
    end
end)

-- animação
