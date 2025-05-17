local assetJson, assetPatch, assetAdd, assetBytes = assets.json, assets.patch, assets.add, assets.bytes
local config = assetJson("/pat/norotting/norotting.config")


local rotItems = {}
for i = 1, #config.rotItems do
  rotItems[config.rotItems[i]] = true
end
local defaultRotItem = assetJson("/items/rotting.config:rottedItem")
rotItems[defaultRotItem] = true


local rotAgingScripts = {}
local patchPath = "/pat/norotting/patch.json"
local patch = { {}, {{op = "add", path = "/pat_norotting", value = true}} }
local ops = patch[1]

for i = 1, #config.rotAgingScripts do
  local script = config.rotAgingScripts[i]
  rotAgingScripts[script] = true

  ops[#ops + 1] = {op = "remove", path = "/itemAgingScripts", search = script}
end
assetAdd(patchPath, patch)


local buildscripts = {}
local files = assets.byExtension("consumable")
for i = 1, #files do
  local file = files[i]
  local data = assetJson(file)

  local itemAgingScripts = data.itemAgingScripts
  if not itemAgingScripts then goto continue end

  local rotItem = data.rottedItem
  if rotItem and not rotItems[rotItem] then goto continue end

  for j = 1, #itemAgingScripts do
    if rotAgingScripts[itemAgingScripts[j]] then goto foundScript end
  end
  goto continue
  ::foundScript::

  if data.builder then
    buildscripts[data.builder] = true
  end
  assetPatch(file, patchPath)

  ::continue::
end


local hook = "\n require('/pat/norotting/builder.lua')"
for builder, _ in next, buildscripts do
  local bytes = assetBytes(builder)
  assetAdd(builder, bytes .. hook)
end
