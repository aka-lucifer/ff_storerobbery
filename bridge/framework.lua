QBCore, ESX = nil, nil

if Config.Framework == "Qbox" and GetResourceState("qbx_core") == "started" then
    Debug("Framework set to Qbox", DebugTypes.Info)
elseif Config.Framework == "QB" and GetResourceState("qb-core") == "started" then
    QBCore = exports['qb-core']:GetCoreObject()
    Debug("Framework set to QB Core", DebugTypes.Info)
elseif Config.Framework == "ESX" and GetResourceState("es_extended") == "started" then
    ESX = exports["es_extended"]:getSharedObject()
    Debug("Framework set to ESX", DebugTypes.Info)
elseif Config.Framework == "Mythic" and GetResourceState("mythic-base") == "started" then
    Debug("Framework set to Mythic", DebugTypes.Info)
elseif Config.Framework == "Custom" then
    Debug("Framework set to custom, you need to fill out the custom functions!", DebugTypes.Info)
else
    Debug("You need to set the Config.Framework to either \"QBCore\" or \"ESX\" or \"Qbox\" or \"Mythic\" or \"Custom\"!", "error")
end