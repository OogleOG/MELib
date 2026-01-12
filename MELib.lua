--[[
    MELib - Extended Utility Library for ME Scripts
    Version: 1.1.0
    
    Clean wrapper/abstraction layer for the base API.
    Pass your own IDs/names - no hardcoded values.
    
    Usage:
        local API = require("api")
        local MELib = require("MELib")
        
        MELib.Bank.Withdraw("Iron scimitar", 1)
        MELib.Combat.Eat(379)
        MELib.NPC.Attack({28619, 28620})
]]--

local ScriptName = "MELib"
local Author = "Oogle"

local API = require("api")
local MELib = {}

MELib.VERSION = "1.1.0"

MELib.Utils = {}

function MELib.Utils.Sleep(min, max)
    max = max or min
    API.RandomSleep2(math.random(min, max), 0, 0)
end

function MELib.Utils.SleepTicks(ticks)
    API.RandomSleep2(ticks * 600, 100, 200)
end

function MELib.Utils.WaitUntil(condition, timeout, interval)
    timeout = timeout or 10000
    interval = interval or 100
    local start = os.clock() * 1000
    while (os.clock() * 1000 - start) < timeout do
        if condition() then return true end
        API.RandomSleep2(interval, 0, 50)
    end
    return false
end

function MELib.Utils.Log(msg)
    print(string.format("[%s] %s", os.date("%H:%M:%S"), tostring(msg)))
end

function MELib.Utils.FormatNumber(n)
    local formatted = tostring(n)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

MELib.Player = {}

function MELib.Player.IsLoggedIn()
    return API.GetGameState2() == 3
end

function MELib.Player.GetTile()
    return API.PlayerCoord()
end

function MELib.Player.GetName()
    return API.GetLocalPlayerName()
end

function MELib.Player.IsMoving()
    return API.ReadPlayerMovin2()
end

function MELib.Player.IsAnimating(loops)
    return API.CheckAnim(loops or 1)
end

function MELib.Player.InCombat()
    return API.LocalPlayer_IsInCombat_() or API.GetInCombBit()
end

function MELib.Player.GetHP()
    return API.GetHP_()
end

function MELib.Player.GetMaxHP()
    return API.GetHPMax_()
end

function MELib.Player.GetHPPercent()
    return API.GetHPrecent()
end

function MELib.Player.GetPrayer()
    return API.GetPray_()
end

function MELib.Player.GetMaxPrayer()
    return API.GetPrayMax_()
end

function MELib.Player.GetPrayerPercent()
    return API.GetPrayPrecent()
end

function MELib.Player.GetAdrenaline()
    return API.GetAddreline_()
end

function MELib.Player.GetSummoning()
    return API.GetSummoningPoints_()
end

function MELib.Player.GetRunEnergy()
    return API.GetRunEnergy_()
end

function MELib.Player.IsRunOn()
    return API.GetRun()
end

function MELib.Player.ToggleRun()
    if not MELib.Player.IsRunOn() and MELib.Player.GetRunEnergy() > 0 then
        API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1465, 4, -1, API.OFF_ACT_GeneralInterface_route)
    end
end

function MELib.Player.DistanceTo(tile)
    if tile.z then
        return API.Dist_FLPW(tile)
    end
    return API.Dist_FLP(tile)
end

function MELib.Player.IsNear(tile, range)
    return API.PInAreaW(tile, range)
end

function MELib.Player.GetWorld()
    return API.GetWorldNR()
end

function MELib.Player.IsMember()
    return API.IsMember()
end

MELib.Skills = {}

MELib.Skills.ATTACK = 0
MELib.Skills.DEFENCE = 2
MELib.Skills.STRENGTH = 4
MELib.Skills.HITPOINTS = 6
MELib.Skills.RANGED = 8
MELib.Skills.PRAYER = 10
MELib.Skills.MAGIC = 12
MELib.Skills.COOKING = 14
MELib.Skills.WOODCUTTING = 16
MELib.Skills.FLETCHING = 18
MELib.Skills.FISHING = 20
MELib.Skills.FIREMAKING = 22
MELib.Skills.CRAFTING = 24
MELib.Skills.SMITHING = 26
MELib.Skills.MINING = 28
MELib.Skills.HERBLORE = 30
MELib.Skills.AGILITY = 32
MELib.Skills.THIEVING = 34
MELib.Skills.SLAYER = 36
MELib.Skills.FARMING = 38
MELib.Skills.RUNECRAFTING = 40
MELib.Skills.HUNTER = 42
MELib.Skills.CONSTRUCTION = 44
MELib.Skills.SUMMONING = 46
MELib.Skills.DUNGEONEERING = 48
MELib.Skills.DIVINATION = 50
MELib.Skills.INVENTION = 52
MELib.Skills.ARCHAEOLOGY = 54
MELib.Skills.NECROMANCY = 56

function MELib.Skills.GetLevel(skill)
    return API.GetSkillsTableSkill(skill)
end

function MELib.Skills.GetBoostedLevel(skill)
    return API.GetSkillsTableSkill(skill + 1)
end

function MELib.Skills.GetXP(skill)
    return API.GetSkillXP(skill)
end

function MELib.Skills.IsBoosted(skill)
    return MELib.Skills.GetBoostedLevel(skill) > MELib.Skills.GetLevel(skill)
end

function MELib.Skills.GetBoost(skill)
    return MELib.Skills.GetBoostedLevel(skill) - MELib.Skills.GetLevel(skill)
end

MELib.Inventory = {}

function MELib.Inventory.GetAll()
    return API.ReadInvArrays33()
end

function MELib.Inventory.Contains(item)
    if type(item) == "table" then
        return API.InvItemFound2(item)
    end
    return API.InvItemFound1(item)
end

function MELib.Inventory.Count(item)
    if type(item) == "table" then
        return API.InvItemcount_2(item)
    end
    return API.InvItemcount_1(item)
end

function MELib.Inventory.StackSize(item)
    if type(item) == "table" then
        return API.InvStackSize(item)
    end
    return API.InvStackSize({item})
end

function MELib.Inventory.IsFull()
    return API.InvFull_()
end

function MELib.Inventory.IsEmpty()
    return API.Invfreecount_() == 28
end

function MELib.Inventory.FreeSlots()
    return API.Invfreecount_()
end

function MELib.Inventory.UsedSlots()
    return 28 - API.Invfreecount_()
end

function MELib.Inventory.Click(item, action)
    action = action or 0
    if type(item) == "table" then
        return API.DoAction_Inventory2(item, action, 1, API.OFF_ACT_GeneralInterface_route)
    end
    return API.DoAction_Inventory1(item, action, 1, API.OFF_ACT_GeneralInterface_route)
end

function MELib.Inventory.Use(item)
    if type(item) == "table" then
        return API.DoAction_Inventory2(item, 0, 1, API.OFF_ACT_GeneralInterface_route1)
    end
    return API.DoAction_Inventory1(item, 0, 1, API.OFF_ACT_GeneralInterface_route1)
end

function MELib.Inventory.UseOn(item1, item2)
    MELib.Inventory.Use(item1)
    API.RandomSleep2(100, 50, 100)
    return MELib.Inventory.Use(item2)
end

function MELib.Inventory.Drop(item)
    if type(item) == "table" then
        return API.DoAction_Inventory2(item, 0, 8, API.OFF_ACT_GeneralInterface_route)
    end
    return API.DoAction_Inventory1(item, 0, 8, API.OFF_ACT_GeneralInterface_route)
end

function MELib.Inventory.DropAll(item)
    local items = MELib.Inventory.GetAll()
    for _, inv in ipairs(items) do
        local shouldDrop = false
        if type(item) == "table" then
            for _, id in ipairs(item) do
                if inv.itemid1 == id then shouldDrop = true break end
            end
        else
            shouldDrop = inv.itemid1 == item
        end
        if shouldDrop then
            API.DoAction_Inventory1(inv.itemid1, 0, 8, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(100, 50, 150)
        end
    end
end

function MELib.Inventory.DropAllExcept(keepItems)
    local items = MELib.Inventory.GetAll()
    for _, inv in ipairs(items) do
        local shouldKeep = false
        if type(keepItems) == "table" then
            for _, id in ipairs(keepItems) do
                if inv.itemid1 == id then shouldKeep = true break end
            end
        else
            shouldKeep = inv.itemid1 == keepItems
        end
        if not shouldKeep and inv.itemid1 > 0 then
            API.DoAction_Inventory1(inv.itemid1, 0, 8, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(100, 50, 150)
        end
    end
end

function MELib.Inventory.GetItem(item)
    local items = MELib.Inventory.GetAll()
    if type(item) == "table" then
        for _, inv in ipairs(items) do
            for _, id in ipairs(item) do
                if inv.itemid1 == id then return inv end
            end
        end
    else
        for _, inv in ipairs(items) do
            if inv.itemid1 == item then return inv end
        end
    end
    return nil
end

MELib.Equipment = {}

MELib.Equipment.HEAD = 0
MELib.Equipment.CAPE = 1
MELib.Equipment.NECK = 2
MELib.Equipment.WEAPON = 3
MELib.Equipment.BODY = 4
MELib.Equipment.SHIELD = 5
MELib.Equipment.LEGS = 7
MELib.Equipment.HANDS = 9
MELib.Equipment.FEET = 10
MELib.Equipment.RING = 12
MELib.Equipment.AMMO = 13
MELib.Equipment.AURA = 14
MELib.Equipment.POCKET = 15

function MELib.Equipment.GetAll()
    return API.ReadEquipment()
end

function MELib.Equipment.IsWearing(slot, item)
    return API.EquipSlotEq1(slot, item)
end

function MELib.Equipment.HasEquipped(item)
    if type(item) == "table" then
        for _, id in ipairs(item) do
            if API.CheckEquipSlot(id) then return true end
        end
        return false
    end
    return API.CheckEquipSlot(item)
end

function MELib.Equipment.Equip(item)
    if MELib.Inventory.Contains(item) then
        return API.DoAction_Inventory1(item, 0, 2, API.OFF_ACT_GeneralInterface_route)
    end
    return false
end

function MELib.Equipment.Unequip(slot)
    return API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1464, slot, -1, API.OFF_ACT_GeneralInterface_route)
end

MELib.Bank = {}

function MELib.Bank.IsOpen()
    return API.BankOpen2()
end

function MELib.Bank.Open(bankObject, distance)
    distance = distance or 20
    if type(bankObject) == "table" then
        API.DoAction_Object2(0x5, 0, bankObject, distance, WPOINT.new(0,0,0))
    else
        API.DoAction_Object1(0x5, 0, {bankObject}, distance)
    end
    return MELib.Utils.WaitUntil(MELib.Bank.IsOpen, 5000)
end

function MELib.Bank.OpenNPC(bankerNPC, distance)
    distance = distance or 20
    if type(bankerNPC) == "table" then
        API.DoAction_NPC(0x5, API.OFF_ACT_InteractNPC_route, bankerNPC, distance, true, 0)
    else
        API.DoAction_NPC(0x5, API.OFF_ACT_InteractNPC_route, {bankerNPC}, distance, true, 0)
    end
    return MELib.Utils.WaitUntil(MELib.Bank.IsOpen, 5000)
end

function MELib.Bank.Close()
    if MELib.Bank.IsOpen() then
        API.KeyboardPress2(0x1B, 60, 100)
        return MELib.Utils.WaitUntil(function() return not MELib.Bank.IsOpen() end, 2000)
    end
    return true
end

function MELib.Bank.GetStack(item)
    if type(item) == "string" then
        return API.BankGetItemStack_str(item)
    end
    return API.BankGetItemStack1(item)
end

function MELib.Bank.Contains(item, minStack)
    minStack = minStack or 1
    if type(item) == "table" then
        for _, id in ipairs(item) do
            if MELib.Bank.GetStack(id) >= minStack then return true end
        end
        return false
    end
    return MELib.Bank.GetStack(item) >= minStack
end

function MELib.Bank.DepositAll()
    if not MELib.Bank.IsOpen() then return false end
    return API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 517, 39, -1, API.OFF_ACT_GeneralInterface_route)
end

function MELib.Bank.DepositAllExcept(keepItems)
    if not MELib.Bank.IsOpen() then return false end
    local items = MELib.Inventory.GetAll()
    for _, inv in ipairs(items) do
        local shouldKeep = false
        if type(keepItems) == "table" then
            for _, id in ipairs(keepItems) do
                if inv.itemid1 == id then shouldKeep = true break end
            end
        else
            shouldKeep = inv.itemid1 == keepItems
        end
        if not shouldKeep and inv.itemid1 > 0 then
            API.DoAction_Bank_Inv(inv.itemid1, 8, API.OFF_ACT_GeneralInterface_route2)
            API.RandomSleep2(100, 50, 100)
        end
    end
    return true
end

function MELib.Bank.Deposit(item, amount)
    if not MELib.Bank.IsOpen() then return false end
    amount = amount or 1
    
    local action = 2  -- Deposit 1
    if amount == "All" or amount == "all" then
        action = 8
    elseif amount == 5 then
        action = 4
    elseif amount == 10 then
        action = 5
    elseif type(amount) == "number" and amount > 1 then
        action = 7  -- Deposit X
    end
    
    API.DoAction_Bank_Inv(item, action, API.OFF_ACT_GeneralInterface_route2)
    
    if action == 7 then
        API.RandomSleep2(600, 100, 200)
        API.TypeString(tostring(amount))
        API.RandomSleep2(100, 50, 100)
        API.KeyboardPress2(0x0D, 60, 100)
    end
    return true
end

function MELib.Bank.DepositWorn()
    if not MELib.Bank.IsOpen() then return false end
    return API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 517, 42, -1, API.OFF_ACT_GeneralInterface_route)
end

function MELib.Bank.DepositBOB()
    if not MELib.Bank.IsOpen() then return false end
    return API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 517, 44, -1, API.OFF_ACT_GeneralInterface_route)
end

function MELib.Bank.Withdraw(item, amount)
    if not MELib.Bank.IsOpen() then return false end
    if not MELib.Bank.Contains(item) then return false end
    
    amount = amount or 1
    local action = 1  -- Withdraw 1
    if amount == "All" or amount == "all" then
        action = 8
    elseif amount == 5 then
        action = 3
    elseif amount == 10 then
        action = 4
    elseif type(amount) == "number" and amount > 1 then
        action = 6  -- Withdraw X
    end
    
    API.DoAction_Bank(item, action, API.OFF_ACT_GeneralInterface_route)
    
    if action == 6 then
        API.RandomSleep2(600, 100, 200)
        API.TypeString(tostring(amount))
        API.RandomSleep2(100, 50, 100)
        API.KeyboardPress2(0x0D, 60, 100)
    end
    return true
end

function MELib.Bank.WithdrawNoted(item, amount)
    API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 517, 19, -1, API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(100, 50, 100)
    local result = MELib.Bank.Withdraw(item, amount)
    API.RandomSleep2(100, 50, 100)
    API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 517, 19, -1, API.OFF_ACT_GeneralInterface_route)
    return result
end

function MELib.Bank.LoadPreset(preset)
    if not MELib.Bank.IsOpen() then return false end
    local keys = {49, 50, 51, 52, 53, 54, 55, 56, 57, 48}
    if keys[preset] then
        API.KeyboardPress2(keys[preset], 60, 100)
        return true
    end
    return false
end

function MELib.Bank.Search(term)
    if not MELib.Bank.IsOpen() then return end
    API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 517, 33, -1, API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(300, 100, 200)
    API.TypeString(term)
end

MELib.Combat = {}

function MELib.Combat.InCombat()
    return API.LocalPlayer_IsInCombat_() or API.GetInCombBit()
end

function MELib.Combat.HasTarget()
    return API.IsTargeting()
end

function MELib.Combat.GetTargetHP()
    return API.GetTargetHealth()
end

function MELib.Combat.Eat(food)
    if MELib.Inventory.Contains(food) then
        return MELib.Inventory.Click(food)
    end
    return false
end

function MELib.Combat.Drink(potion)
    if MELib.Inventory.Contains(potion) then
        return MELib.Inventory.Click(potion)
    end
    return false
end

function MELib.Combat.UseAbility(ability)
    local ab
    if type(ability) == "string" then
        ab = API.GetABs_name(ability, true)
    else
        ab = API.GetABs_id(ability)
    end
    
    if ab and ab.id > 0 and ab.enabled and ab.cooldown_timer == 0 then
        return API.DoAction_Ability_Direct(ab, 1, API.OFF_ACT_GeneralInterface_route)
    end
    return false
end

function MELib.Combat.IsAbilityReady(ability)
    local ab
    if type(ability) == "string" then
        ab = API.GetABs_name(ability, true)
    else
        ab = API.GetABs_id(ability)
    end
    
    if ab and ab.id > 0 then
        return ab.enabled and ab.cooldown_timer == 0
    end
    return false
end

function MELib.Combat.GetAbilityCooldown(ability)
    local ab
    if type(ability) == "string" then
        ab = API.GetABs_name(ability, true)
    else
        ab = API.GetABs_id(ability)
    end
    
    if ab and ab.id > 0 then
        return ab.cooldown_timer
    end
    return -1
end

function MELib.Combat.ToggleQuickPrayers()
    return API.DoAction_Button_QP()
end

function MELib.Combat.QuickPrayersOn()
    return API.GetQuickPray()
end

function MELib.Combat.SetPrayer(prayerVB, state)
    return API.QuickPray_option(prayerVB, state and 1 or 0)
end

function MELib.Combat.IsPrayerOn(prayerVB)
    return API.VB_GetBit(prayerVB, 0) == 1
end

function MELib.Combat.Attack(npc, distance)
    distance = distance or 20
    if type(npc) == "table" then
        return API.DoAction_NPC(0x2a, API.OFF_ACT_AttackNPC_route, npc, distance, true, 100)
    end
    return API.DoAction_NPC(0x2a, API.OFF_ACT_AttackNPC_route, {npc}, distance, true, 100)
end

function MELib.Combat.AttackByName(npcName, distance)
    distance = distance or 20
    if type(npcName) == "table" then
        return API.DoAction_NPC_str(0x2a, API.OFF_ACT_AttackNPC_route, npcName, distance, true, 100)
    end
    return API.DoAction_NPC_str(0x2a, API.OFF_ACT_AttackNPC_route, {npcName}, distance, true, 100)
end

MELib.Buffs = {}

function MELib.Buffs.GetAll()
    return API.Buffbar_GetAllIDs()
end

function MELib.Buffs.Has(buff)
    if type(buff) == "table" then
        local buffs = MELib.Buffs.GetAll()
        for _, b in ipairs(buffs) do
            for _, id in ipairs(buff) do
                if b.id == id then return true end
            end
        end
        return false
    end
    return API.Buffbar_GetIDstatus(buff).id > 0
end

function MELib.Buffs.Get(buff)
    local b = API.Buffbar_GetIDstatus(buff)
    if b.id > 0 then return b end
    return nil
end

function MELib.Buffs.GetDuration(buff)
    local b = API.Buffbar_GetIDstatus(buff)
    if b.id > 0 then return b.conv_text or 0 end
    return -1
end

function MELib.Buffs.GetDebuffs()
    return API.DeBuffbar_GetAllIDs()
end

function MELib.Buffs.HasDebuff(debuff)
    return API.DeBuffbar_GetIDstatus(debuff).id > 0
end

MELib.NPC = {}

function MELib.NPC.Find(npc, distance)
    distance = distance or 50
    local ids = type(npc) == "table" and npc or {npc}
    local npcs = API.GetAllObjArray1(ids, distance, {1})
    if #npcs > 0 then return API.Math_SortAODist(npcs) end
    return nil
end

function MELib.NPC.FindByName(npcName, distance)
    distance = distance or 50
    local names = type(npcName) == "table" and npcName or {npcName}
    local npcs = API.GetAllObjArrayInteract_str(names, distance, {1})
    if #npcs > 0 then return API.Math_SortAODist(npcs) end
    return nil
end

function MELib.NPC.FindAll(npc, distance)
    distance = distance or 50
    local ids = type(npc) == "table" and npc or {npc}
    return API.GetAllObjArray1(ids, distance, {1})
end

function MELib.NPC.Exists(npc, distance)
    return MELib.NPC.Find(npc, distance) ~= nil
end

function MELib.NPC.Interact(npc, distance)
    distance = distance or 20
    local ids = type(npc) == "table" and npc or {npc}
    return API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route, ids, distance, true, 0)
end

function MELib.NPC.InteractByName(npcName, distance)
    distance = distance or 20
    local names = type(npcName) == "table" and npcName or {npcName}
    return API.DoAction_NPC_str(0x29, API.OFF_ACT_InteractNPC_route, names, distance, true, 0)
end

function MELib.NPC.TalkTo(npc, distance)
    return MELib.NPC.Interact(npc, distance)
end

function MELib.NPC.InteractOption2(npc, distance)
    distance = distance or 20
    local ids = type(npc) == "table" and npc or {npc}
    return API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route2, ids, distance, true, 0)
end

function MELib.NPC.InteractOption3(npc, distance)
    distance = distance or 20
    local ids = type(npc) == "table" and npc or {npc}
    return API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route3, ids, distance, true, 0)
end

function MELib.NPC.InteractDirect(npcObject, action, route)
    action = action or 0x29
    route = route or API.OFF_ACT_InteractNPC_route
    return API.DoAction_NPC__Direct(action, route, npcObject)
end

MELib.Objects = {}

function MELib.Objects.Find(obj, distance)
    distance = distance or 50
    local ids = type(obj) == "table" and obj or {obj}
    local objects = API.GetAllObjArray1(ids, distance, {0, 12})
    if #objects > 0 then return API.Math_SortAODist(objects) end
    return nil
end

function MELib.Objects.FindByName(objName, distance)
    distance = distance or 50
    local names = type(objName) == "table" and objName or {objName}
    local objects = API.GetAllObjArrayInteract_str(names, distance, {0, 12})
    if #objects > 0 then return API.Math_SortAODist(objects) end
    return nil
end

function MELib.Objects.FindAll(obj, distance)
    distance = distance or 50
    local ids = type(obj) == "table" and obj or {obj}
    return API.GetAllObjArray1(ids, distance, {0, 12})
end

function MELib.Objects.Exists(obj, distance)
    return MELib.Objects.Find(obj, distance) ~= nil
end

function MELib.Objects.Interact(obj, distance)
    distance = distance or 20
    local ids = type(obj) == "table" and obj or {obj}
    return API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route0, ids, distance)
end

function MELib.Objects.InteractByName(objName, distance)
    distance = distance or 20
    local names = type(objName) == "table" and objName or {objName}
    return API.DoAction_Object_string1(0x29, API.OFF_ACT_GeneralObject_route0, names, distance)
end

function MELib.Objects.InteractOption2(obj, distance)
    distance = distance or 20
    local ids = type(obj) == "table" and obj or {obj}
    return API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route1, ids, distance)
end

function MELib.Objects.InteractOption3(obj, distance)
    distance = distance or 20
    local ids = type(obj) == "table" and obj or {obj}
    return API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route2, ids, distance)
end

function MELib.Objects.InteractDirect(objObject, action, route)
    action = action or 0x29
    route = route or API.OFF_ACT_GeneralObject_route0
    return API.DoAction_Object_Direct(action, route, objObject)
end

function MELib.Objects.UseItemOn(item, obj, distance)
    distance = distance or 20
    MELib.Inventory.Use(item)
    API.RandomSleep2(100, 50, 100)
    local ids = type(obj) == "table" and obj or {obj}
    return API.DoAction_Object1(0x29, API.GeneralObject_route_useon, ids, distance)
end

MELib.GroundItems = {}

function MELib.GroundItems.Find(item, distance)
    distance = distance or 50
    local ids = type(item) == "table" and item or {item}
    local items = API.GetAllObjArray1(ids, distance, {3})
    if #items > 0 then return API.Math_SortAODist(items) end
    return nil
end

function MELib.GroundItems.FindAll(item, distance)
    distance = distance or 50
    local ids = type(item) == "table" and item or {item}
    return API.GetAllObjArray1(ids, distance, {3})
end

function MELib.GroundItems.Exists(item, distance)
    return MELib.GroundItems.Find(item, distance) ~= nil
end

function MELib.GroundItems.Loot(item, distance)
    distance = distance or 20
    local ids = type(item) == "table" and item or {item}
    return API.DoAction_G_Items1(0x29, ids, distance)
end

function MELib.GroundItems.LootArea(item, distance, tile, radius)
    distance = distance or 20
    radius = radius or 5
    local ids = type(item) == "table" and item or {item}
    return API.DoAction_Loot_w(ids, distance, tile, radius)
end

MELib.Interface = {}

function MELib.Interface.IsOpen(interfaceId)
    return API.GetInterfaceOpenBySize(interfaceId)
end

function MELib.Interface.DialogueOpen()
    return API.Compare2874Status(8, false) or API.Compare2874Status(9, false)
end

function MELib.Interface.SelectOption(num)
    local keys = {49, 50, 51, 52, 53}
    if keys[num] then
        API.KeyboardPress2(keys[num], 60, 100)
        return true
    end
    return false
end

function MELib.Interface.Continue()
    API.KeyboardPress2(32, 60, 100)
end

function MELib.Interface.Close()
    API.KeyboardPress2(0x1B, 60, 100)
end

function MELib.Interface.WaitFor(interfaceId, timeout)
    timeout = timeout or 5000
    return MELib.Utils.WaitUntil(function()
        return MELib.Interface.IsOpen(interfaceId)
    end, timeout)
end

function MELib.Interface.LootWindowOpen()
    return API.LootWindowOpen_2()
end

function MELib.Interface.LootAll()
    if MELib.Interface.LootWindowOpen() then
        return API.DoAction_LootAll_Button()
    end
    return false
end

function MELib.Interface.CloseLootWindow()
    if MELib.Interface.LootWindowOpen() then
        API.DoAction_Loot_w_Close()
    end
end

MELib.Movement = {}

function MELib.Movement.WalkTo(tile)
    if tile.z then
        return API.DoAction_WalkerW(tile)
    end
    return API.DoAction_WalkerF(tile)
end

function MELib.Movement.WalkToAndWait(tile, tolerance, timeout)
    tolerance = tolerance or 2
    timeout = timeout or 10000
    MELib.Movement.WalkTo(tile)
    return MELib.Utils.WaitUntil(function()
        return MELib.Player.DistanceTo(tile) <= tolerance
    end, timeout)
end

function MELib.Movement.IsMoving()
    return API.ReadPlayerMovin2()
end

function MELib.Movement.WaitUntilStopped(timeout)
    timeout = timeout or 10000
    return MELib.Utils.WaitUntil(function()
        return not MELib.Movement.IsMoving()
    end, timeout)
end

function MELib.Movement.Surge()
    return MELib.Combat.UseAbility("Surge")
end

function MELib.Movement.Escape()
    return MELib.Combat.UseAbility("Escape")
end

function MELib.Movement.BladedDive(tile)
    return API.DoAction_Dive_Tile(tile, 0)
end

function MELib.Movement.ClickTile(tile)
    if tile.z then
        return API.DoAction_Tile(tile)
    end
    return API.DoAction_TileF(tile)
end

MELib.Familiar = {}

function MELib.Familiar.IsSummoned()
    return API.GetSummoningPoints_() > 0
end

function MELib.Familiar.Call()
    return API.DoAction_Button_FO(0)
end

function MELib.Familiar.Special()
    return API.DoAction_Button_FO(1)
end

function MELib.Familiar.Attack()
    return API.DoAction_Button_FO(2)
end

function MELib.Familiar.Dismiss()
    return API.DoAction_Button_FO(4)
end

function MELib.Familiar.Interact()
    return API.DoAction_Button_FO(6)
end

function MELib.Familiar.Renew()
    return API.DoAction_Button_FO(7)
end

function MELib.Familiar.GiveBOB()
    return API.DoAction_Button_FO(8)
end

function MELib.Familiar.TakeBOB()
    return API.DoAction_Button_FO(9)
end

function MELib.Familiar.RestorePoints()
    return API.DoAction_Button_FO(10)
end

MELib.Varbit = {}

function MELib.Varbit.Get(id)
    local vb = API.VB_FindPSettinOrder(id)
    if vb then return vb.state end
    return 0
end

function MELib.Varbit.GetBit(id, pos)
    return API.VB_GetBit(id, pos)
end

function MELib.Varbit.IsBitSet(id, pos)
    return API.VB_GetBit(id, pos) == 1
end

MELib.Chat = {}

function MELib.Chat.GetMessages(count)
    return API.GetChatMessage(0, count or 10)
end

function MELib.Chat.Contains(text, count)
    local messages = MELib.Chat.GetMessages(count or 10)
    for _, msg in ipairs(messages) do
        if string.find(msg:lower(), text:lower()) then return true end
    end
    return false
end

function MELib.Chat.Type(text)
    API.TypeString(text)
end

function MELib.Chat.Send(text)
    API.TypeString(text)
    API.KeyboardPress2(0x0D, 60, 100)
end

MELib.Area = {}

function MELib.Area.InArea(x1, y1, x2, y2, floor)
    local pos = API.PlayerCoord()
    if floor and pos.z ~= floor then return false end
    return pos.x >= x1 and pos.x <= x2 and pos.y >= y1 and pos.y <= y2
end

function MELib.Area.InRadius(tile, radius)
    return MELib.Player.DistanceTo(tile) <= radius
end

MELib.Death = {}

function MELib.Death.HasItemsToReclaim()
    return API.HasDeathItemsReclaim()
end

function MELib.Death.IsInDeathOffice()
    return API.IsInDeathOffice()
end

return MELib
