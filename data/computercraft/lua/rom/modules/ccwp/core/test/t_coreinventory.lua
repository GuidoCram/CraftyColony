local t_coreinventory = {}

local corelog = require "corelog"
local coreinventory = require "coreinventory"

function t_coreinventory.T_SelectItem()
    corelog.WriteToLog("Selecing minecraft:crafting_table")
    corelog.WriteToLog(coreinventory.SelectItem("minecraft:crafting_table"))
    corelog.WriteToLog("Selecing minecraft:diamond_pickaxe")
    corelog.WriteToLog(coreinventory.SelectItem("minecraft:diamond_pickaxe"))
end

function t_coreinventory.T_CanEquip()
    corelog.WriteToLog("Can we equip minecraft:crafting_table?")
    corelog.WriteToLog(coreinventory.CanEquip("minecraft:crafting_table"))
    corelog.WriteToLog("Can we equip minecraft:diamond_pickaxe?")
    corelog.WriteToLog(coreinventory.CanEquip("minecraft:diamond_pickaxe"))
    corelog.WriteToLog("Can we equip computercraft:wireless_modem_normal?")
    corelog.WriteToLog(coreinventory.CanEquip("computercraft:wireless_modem_normal"))
end

function t_coreinventory.T_Equip()
    corelog.WriteToLog("Equiping minecraft:crafting_table")
    corelog.WriteToLog(coreinventory.Equip("minecraft:crafting_table", "right"))
    corelog.WriteToLog("Equiping minecraft:diamond_pickaxe")
    corelog.WriteToLog(coreinventory.Equip("minecraft:diamond_pickaxe", "right"))
end

return t_coreinventory
