# MELib

A comprehensive utility library extending the base ME API with higher-level convenience functions for RuneScape 3 scripting.

## Overview

MELib provides a cleaner interface for common scripting tasks including banking, inventory management, combat, movement, and more. Rather than dealing with low-level API calls directly, MELib wraps these into intuitive, readable functions.

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
| Utils | Sleep functions, WaitUntil, logging, formatting |
| Player | Health, prayer, adrenaline, position, movement state |
| Skills | Level lookup, XP, boost detection |
| Inventory | Item checks, counting, clicking, dropping |
| Equipment | Slot checking, equipping, unequipping |
| Bank | Open, close, deposit, withdraw, presets |
| Combat | Eating, potions, abilities, prayers, targeting |
| Buffs | Active buff detection and duration |
| NPC | Finding and interacting with NPCs |
| Objects | Finding and interacting with game objects |
| GroundItems | Looting items from the ground |
| Interface | Dialogue handling, interface state checks |
| Movement | Walking, surging, bladed dive, lodestones |
| Familiar | Summoning interactions, BOB management |
| Death | Death office and reclaim detection |
| Varbit | Varbit reading utilities |
| Chat | Message retrieval and sending |
| Area | Position and area checks |
| StateMachine | Helper for state-based script flow |

## Usage Examples

### Basic Player Checks

```lua
-- Health and prayer
if MELib.Player.GetHealthPercent() < 50 then
    MELib.Combat.EatFood({385, 391})
end

if MELib.Player.GetPrayerPercent() < 30 then
    MELib.Combat.DrinkPotion({2434, 139, 141, 143})
end

-- Position
local pos = MELib.Player.GetTile()
print("Current position: " .. pos.x .. ", " .. pos.y)

-- Distance check
if MELib.Player.DistanceTo(targetTile) < 5 then
    -- Do something
end
```

### Inventory Management

```lua
-- Check for items
if MELib.Inventory.Contains(1511) then
    print("Has oak logs")
end

-- Count items
local count = MELib.Inventory.Count({1511, 1521})

-- Check space
if MELib.Inventory.FreeSlots() < 5 then
    -- Bank soon
end

-- Drop items
MELib.Inventory.Drop(1511)

-- Drop all except specific items
MELib.Inventory.DropAllExcept({590, 1351})  -- Keep tinderbox and axe
```

### Banking

```lua
-- Open nearest bank
MELib.Bank.Open(50)

-- Wait for bank to open, then deposit
if MELib.Utils.WaitUntil(function() return MELib.Bank.IsOpen() end, 5000) then
    MELib.Bank.DepositAll()
    MELib.Bank.Withdraw(1511, 28)  -- Withdraw 28 oak logs
    MELib.Bank.Close()
end

-- Load preset
if MELib.Bank.IsOpen() then
    MELib.Bank.LoadPreset(1)
end
```

### Combat

```lua
-- Attack NPC by ID
MELib.Combat.AttackNPC({1234, 1235}, 20)

-- Use ability
if MELib.Combat.IsAbilityReady("Overpower") then
    MELib.Combat.UseAbility("Overpower")
end

-- Prayer management
if not MELib.Combat.QuickPrayersActive() then
    MELib.Combat.ToggleQuickPrayers()
end

-- Check buffs
if not MELib.Buffs.HasBuff(26093) then  -- Overload
    MELib.Combat.DrinkPotion({23531, 23532, 23533, 23534})
end
```

### WaitUntil

The `WaitUntil` function is used to pause execution until a condition is met or timeout occurs.

```lua
-- Signature
MELib.Utils.WaitUntil(condition, timeout, interval)
-- condition: function returning boolean
-- timeout: maximum wait time in ms (default 10000)
-- interval: check frequency in ms (default 100)

-- Wait for player to stop moving
MELib.Utils.WaitUntil(function()
    return not MELib.Player.IsMoving()
end, 10000)

-- Wait for bank with success check
local opened = MELib.Utils.WaitUntil(function()
    return MELib.Bank.IsOpen()
end, 5000)

if opened then
    -- Continue with banking
else
    -- Handle timeout
end
```

### Movement

```lua
-- Walk to tile
MELib.Movement.WalkTo(WPOINT.new(3200, 3200, 0))

-- Walk and wait until arrived
MELib.Movement.WalkToAndWait(WPOINT.new(3200, 3200, 0), 2, 10000)

-- Use lodestone
MELib.Movement.Lodestone(MELib.Movement.LODESTONES.VARROCK)

-- Surge
MELib.Movement.Surge()
```

### State Machine

For more complex scripts, MELib includes a simple state machine helper:

```lua
local states = {
    BANK = function()
        if not MELib.Bank.IsOpen() then
            MELib.Bank.Open()
            return "BANK"
        end
        MELib.Bank.DepositAll()
        MELib.Bank.Withdraw(1511, 28)
        MELib.Bank.Close()
        return "WALK_TO_TREES"
    end,
    
    WALK_TO_TREES = function()
        MELib.Movement.WalkTo(treeTile)
        MELib.Utils.WaitUntil(function()
            return not MELib.Player.IsMoving()
        end, 10000)
        return "CHOP"
    end,
    
    CHOP = function()
        if MELib.Inventory.IsFull() then
            return "BANK"
        end
        MELib.Objects.Interact({1234}, 20)  -- Tree ID
        MELib.Utils.SleepTicks(3)
        return "CHOP"
    end
}

local sm = MELib.StateMachine.Create(states)
sm:SetState("BANK")

while API.Read_LoopyLoop() do
    local nextState = sm:Run()
    if nextState then
        sm:SetState(nextState)
    end
    MELib.Utils.Sleep(100, 200)
end
```

## Module Reference

### MELib.Utils

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| Sleep | min, max | void | Random sleep between min-max ms |
| SleepTicks | ticks | void | Sleep for game ticks (1 tick = 600ms) |
| WaitUntil | condition, timeout, interval | boolean | Wait for condition or timeout |
| Log | msg, level | void | Print timestamped log message |
| FormatNumber | n | string | Format number with commas |
| XPToLevel | skill, targetLevel | number | Calculate XP remaining |
| AntiBan | - | void | Random anti-ban action |

### MELib.Player

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| IsLoggedIn | - | boolean | Check login state |
| GetTile | - | WPOINT | Current position |
| GetName | - | string | Player name |
| IsMoving | - | boolean | Movement state |
| IsAnimating | loops | boolean | Animation state |
| InCombat | - | boolean | Combat state |
| GetHealthPercent | - | number | HP as 0-100 |
| GetHealth | - | number | Current HP |
| GetMaxHealth | - | number | Max HP |
| GetPrayer | - | number | Current prayer points |
| GetMaxPrayer | - | number | Max prayer points |
| GetPrayerPercent | - | number | Prayer as 0-100 |
| GetAdrenaline | - | number | Current adrenaline |
| GetSummoningPoints | - | number | Summoning points |
| IsMember | - | boolean | Membership status |
| DistanceTo | tile | number | Distance to tile |
| IsNear | tile, range | boolean | Within range of tile |
| GetRunEnergy | - | number | Run energy 0-100 |
| IsRunEnabled | - | boolean | Run toggle state |
| ToggleRun | - | void | Toggle run on |
| GetWorld | - | number | Current world |

### MELib.Inventory

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| GetAll | - | table | All inventory items |
| Contains | itemId | boolean | Has item in inventory |
| Count | itemId | number | Count of item slots |
| GetStackCount | itemId | number | Total stack amount |
| IsFull | - | boolean | Inventory full |
| IsEmpty | - | boolean | Inventory empty |
| FreeSlots | - | number | Empty slot count |
| UsedSlots | - | number | Used slot count |
| Click | itemId, action | boolean | Interact with item |
| UseItemOnItem | id1, id2 | boolean | Use item on item |
| Drop | itemId | boolean | Drop item |
| DropAllExcept | keepIds | void | Drop all but listed |
| GetItem | itemId | IInfo | Get item data |

### MELib.Bank

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| IsOpen | - | boolean | Bank open state |
| Open | distance | boolean | Open nearest bank |
| Close | - | boolean | Close bank |
| GetItemStack | itemId | number | Stack in bank |
| Contains | itemId, minStack | boolean | Has item in bank |
| DepositAll | - | boolean | Deposit all items |
| DepositAllExcept | keepIds | boolean | Deposit except listed |
| DepositWornItems | - | boolean | Deposit equipment |
| DepositBOB | - | boolean | Deposit familiar inv |
| Withdraw | itemId, amount | boolean | Withdraw item |
| LoadPreset | preset | boolean | Load preset 1-10 |
| Search | searchTerm | void | Search bank |

### MELib.Combat

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| InCombat | - | boolean | Combat state |
| GetTargetHealth | - | number | Target HP percent |
| HasTarget | - | boolean | Has valid target |
| EatFood | foodIds | boolean | Eat food from list |
| DrinkPotion | potionIds | boolean | Drink potion |
| UseAbility | abilityName | boolean | Use ability by name |
| UseAbilityById | abilityId | boolean | Use ability by ID |
| IsAbilityReady | abilityName | boolean | Check cooldown |
| GetAbilityCooldown | abilityName | number | Get cooldown ticks |
| ToggleQuickPrayers | - | void | Toggle quick prayers |
| QuickPrayersActive | - | boolean | Prayer state |
| ActivatePrayer | prayerVB | boolean | Turn on prayer |
| DeactivatePrayer | prayerVB | boolean | Turn off prayer |
| IsPrayerActive | prayerVB | boolean | Check prayer state |
| AttackNPC | npcIds, distance | boolean | Attack by ID |
| AttackNPCByName | npcNames, distance | boolean | Attack by name |

### MELib.Buffs

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| GetAll | - | table | All active buffs |
| HasBuff | buffId | boolean | Check buff active |
| GetBuff | buffId | Bbar | Get buff data |
| GetDuration | buffId | number | Remaining duration |
| GetDebuffs | - | table | All active debuffs |
| HasDebuff | debuffId | boolean | Check debuff active |

## Notes

- All distance parameters default to sensible values if not provided
- Item parameters accept either single IDs or tables of IDs
- The library does not modify or extend the base API object
- State machine states should return the next state name

## Version

1.0.0

## License

MIT License - Use freely, modify as needed.
