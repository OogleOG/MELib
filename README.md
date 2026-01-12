# MELib

A utility library extending the ME API with cleaner wrapper functions for RuneScape 3 scripting.

## Overview

MELib wraps the base API classes (Inventory, Equipment, Familiars, etc.) and raw API functions into a consistent, easy-to-use interface. Pass item names or IDs directly - no hardcoded values in the library.

## Installation

1. Download `MELib.lua`
2. Place it in your scripts directory alongside `api.lua`
3. Require it in your script:

```lua
local API = require("api")
local MELib = require("MELib")
```

## Modules

| Module | Description |
|--------|-------------|
| Utils | Sleep, WaitUntil, logging |
| Player | HP, prayer, adrenaline, position, run |
| Skills | Levels, XP, boosts |
| Inventory | Items, counts, use, drop, equip |
| Equipment | Worn items, slots, unequip |
| Bank | Deposit, withdraw, presets |
| Combat | Eat, drink, abilities, prayers |
| Buffs | Active buffs and debuffs |
| NPC | Find, attack, interact |
| Objects | Find, interact |
| GroundItems | Find, loot |
| Interface | Dialogue, windows |
| Movement | Walk, surge, bladed dive |
| Familiar | BOB, specials, summoning |
| GrandExchange | Buy, sell, orders |
| Item | Item data lookup |
| Varbit | Varbit reading |
| Chat | Messages |
| Area | Position checks |
| Death | Reclaim checks |

## Usage Examples

### Inventory

```lua
-- Check for items (accepts ID, name, or table)
MELib.Inventory.Contains("Shark")
MELib.Inventory.Contains(385)
MELib.Inventory.Contains({385, 391, 397})

-- Count and slots
local count = MELib.Inventory.Count("Shark")
local free = MELib.Inventory.FreeSlots()

-- Actions
MELib.Inventory.Use("Shark")
MELib.Inventory.Drop("Bones")
MELib.Inventory.Eat("Shark")
MELib.Inventory.Equip("Dragon scimitar")
MELib.Inventory.UseOn("Knife", "Logs")
```

### Equipment

```lua
-- Check worn items
MELib.Equipment.Contains("Amulet of glory")
MELib.Equipment.ContainsAny({"Dragon boots", "Bandos boots"})

-- Get specific slots
local weapon = MELib.Equipment.GetMainhand()
local helm = MELib.Equipment.GetHelm()

-- Unequip
MELib.Equipment.Unequip("Dragon scimitar")
```

### Bank

```lua
-- Open/close
if MELib.Bank.IsOpen() then
    MELib.Bank.DepositAll()
    MELib.Bank.Withdraw("Shark", 10)
    MELib.Bank.Withdraw(385, "All")
    MELib.Bank.LoadPreset(1)
    MELib.Bank.Close()
end

-- Check bank contents
if MELib.Bank.Contains("Shark", 100) then
    -- Has at least 100 sharks
end
```

### Combat

```lua
-- Health management
if MELib.Player.GetHPPercent() < 50 then
    MELib.Combat.Eat("Shark")
end

-- Abilities
if MELib.Combat.IsAbilityReady("Overpower") then
    MELib.Combat.UseAbility("Overpower")
end

-- Prayers
MELib.Combat.ToggleQuickPrayers()
```

### NPCs and Objects

```lua
-- Using Interact class (name + action)
MELib.NPC.Interact("Banker", "Bank")
MELib.Objects.Interact("Oak tree", "Chop down")

-- Using IDs
MELib.NPC.Attack({1234, 1235}, 20)
MELib.Objects.InteractById({12345}, 20)

-- Finding
local npc = MELib.NPC.FindByName("Guard")
if npc then
    MELib.NPC.InteractDirect(npc)
end
```

### Familiar

```lua
if MELib.Familiar.IsSummoned() then
    local timeLeft = MELib.Familiar.GetTimeRemaining()
    
    if MELib.Familiar.HasBOB() then
        MELib.Familiar.GiveAll()
        MELib.Familiar.TakeAll()
    end
    
    MELib.Familiar.CastSpecial()
end
```

### WaitUntil

```lua
-- Wait for condition with timeout
MELib.Utils.WaitUntil(function()
    return MELib.Bank.IsOpen()
end, 5000)

-- With return check
local success = MELib.Utils.WaitUntil(function()
    return not MELib.Player.IsMoving()
end, 10000)

if success then
    -- Player stopped
end
```

### Grand Exchange

```lua
if MELib.GrandExchange.IsOpen() then
    MELib.GrandExchange.Buy(385, 100, 1500)  -- Buy 100 sharks at 1500gp
    
    local slot = MELib.GrandExchange.FindOrder(385)
    if slot >= 0 then
        MELib.GrandExchange.CancelOrder(slot)
    end
end
```

### Item Lookup

```lua
local itemData = MELib.Item.Get("Shark")
print(itemData.name)
print(itemData.value)
print(itemData.stackable)

-- Search items
local results = MELib.Item.GetAll("rune", true)  -- partial match
```

## API Classes Used

MELib uses these API classes internally:

- `Inventory` - Inventory management
- `Equipment` - Worn equipment
- `Familiars` - Summoning familiars
- `Interact` - NPC/Object interactions by name
- `GrandExchange` - GE operations
- `Item` - Item data lookup

Plus raw API functions for Bank, Buffs, Combat, Movement, etc.

## Function Reference

### MELib.Utils

| Function | Description |
|----------|-------------|
| Sleep(min, max) | Random sleep in ms |
| SleepTicks(n) | Sleep for n game ticks |
| WaitUntil(fn, timeout, interval) | Wait for condition |
| Log(msg) | Print timestamped message |
| FormatNumber(n) | Format with commas |

### MELib.Inventory

| Function | Description |
|----------|-------------|
| GetAll() | Get all items |
| Contains(item) | Has item |
| ContainsAll(items) | Has all items |
| ContainsAny(items) | Has any item |
| Count(item) | Get amount |
| IsFull() | Check if full |
| IsEmpty() | Check if empty |
| FreeSlots() | Get free slots |
| Use(item) | Use item |
| UseOn(item1, item2) | Use item on item |
| Drop(item) | Drop item |
| Eat(item) | Eat food |
| Equip(item) | Equip item |
| Rub(item) | Rub jewelry |

### MELib.Bank

| Function | Description |
|----------|-------------|
| IsOpen() | Check if open |
| Close() | Close bank |
| GetItemStack(item) | Get stack size |
| Contains(item, min) | Has item with min stack |
| DepositAll() | Deposit all |
| DepositWornItems() | Deposit equipment |
| Withdraw(item, amount) | Withdraw item |
| Deposit(item, amount) | Deposit item |
| LoadPreset(n) | Load preset 1-10 |

### MELib.Combat

| Function | Description |
|----------|-------------|
| InCombat() | Check combat state |
| HasTarget() | Has valid target |
| GetTargetHealth() | Target HP percent |
| Eat(food) | Eat food |
| Drink(potion) | Drink potion |
| UseAbility(name) | Use ability by name |
| UseAbilityById(id) | Use ability by ID |
| IsAbilityReady(name) | Check cooldown |
| ToggleQuickPrayers() | Toggle prayers |

### MELib.Familiar

| Function | Description |
|----------|-------------|
| IsSummoned() | Has familiar |
| HasBOB() | Has beast of burden |
| GetName() | Familiar name |
| GetTimeRemaining() | Time left |
| CastSpecial() | Use special |
| GiveAll() | Give items to BOB |
| TakeAll() | Take from BOB |
| StorageContains(item) | Check BOB contents |

## Version

2.0.0

## License

MIT
