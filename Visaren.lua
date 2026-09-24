local _, currentClass, classID = UnitClass("player")

local spellNames = {}
local spellIcons = {}

-- Set variables for selected class
local MAX_FRAMES_COUNT = 0
if currentClass == "WARLOCK" then
    MAX_FRAMES_COUNT = #spellNamesWarlock
    spellNames = spellNamesWarlock
    spellIcons = spellIconsWarlock
elseif currentClass == "DRUID" then
    MAX_FRAMES_COUNT = #spellNamesDruid
    spellNames = spellNamesDruid
    spellIcons = spellIconsDruid
end

-- Specific for Burning Rush
local burningRushName = "Burning Rush"
local burningRushIcon = GetSpellTexture(111400)

local pivotIndex = math.floor((MAX_FRAMES_COUNT + 1) / 2)
local iconSize = 32
local yOffset = -100

-- Frames for buffs
local f = {}
for i=1, MAX_FRAMES_COUNT do
    f[i] = CreateFrame("Frame", nil, UIParent) 
    f[i]:SetSize(iconSize, iconSize)
end

-- Set the frame a bit down from center, pivot to left and right depending on how many spells are available
for i = 1, MAX_FRAMES_COUNT do
    if i == pivotIndex then
        f[i]:SetPoint("CENTER", UIParent, "CENTER", 0, yOffset) 
    elseif i < pivotIndex then
        local offset = pivotIndex - i
        f[i]:SetPoint("RIGHT", f[pivotIndex], "LEFT", -10 - (offset - 1) * (iconSize + 10), 0)
    else
        local offset = i - pivotIndex
        f[i]:SetPoint("LEFT", f[pivotIndex], "RIGHT", 10 + (offset - 1) * (iconSize + 10), 0)
    end
end

-- Textures for buffs
local tex = {}
for i=1, MAX_FRAMES_COUNT do
    tex[i] = f[i]:CreateTexture(nil, "BACKGROUND")
    tex[i]:SetAllPoints()
    tex[i]:SetTexture(spellIcons[i])

    local font = f[i]:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    font:SetPoint("BOTTOM", f[i], "BOTTOM", 0, -2)
    font:SetText("")
    f[i].timeText = font

    f[i]:Hide()
end

-- Frame for Burning Rush
local brf = CreateFrame("Frame", nil, UIParent)
brf:SetSize(iconSize, iconSize)
brf:SetPoint("CENTER", UIParent, "CENTER", 0, 0) 

-- Texture for Burning Rush
local brtex = brf:CreateTexture(nil, "BACKGROUND")
brtex:SetAllPoints()
brtex:SetTexture(burningRushIcon)
brf:Hide()

local function UpdateIcon()
    for i=1, MAX_FRAMES_COUNT do
        if spellNames[i] then
            local name, icon, count, debuffType, duration, expirationTime = AuraUtil.FindAuraByName(spellNames[i], "player")
            if name then
                f[i]:Show()

                -- Time remaining
                if expirationTime and duration and duration > 0 then
                    local remaining = expirationTime - GetTime()
                    if remaining < 0 then remaining = 0 end

                    f[i].timeText:SetText(string.format("%d", remaining))
                else
                    f[i].timeText:SetText("")
                end
            else
                f[i]:Hide()
                f[i].timeText:SetText("")
            end
        else
            f[i]:Hide()
            f[i].timeText:SetText("")
        end
    end

    local brName = AuraUtil.FindAuraByName(burningRushName, "player")
    if brName then
        brf:Show()
    else
        brf:Hide()
    end

end

local updater = CreateFrame("Frame")
local elapsed = 0
updater:SetScript("OnUpdate", function(self, delta)
    elapsed = elapsed + delta
    if elapsed > 0.1 then
        UpdateIcon()
        elapsed = 0
    end
end)

local e = CreateFrame("Frame")
e:RegisterEvent("PLAYER_LOGIN")
e:RegisterEvent("UNIT_AURA")

e:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_LOGIN" then
        UpdateIcon()
    elseif event == "UNIT_AURA" and unit == "player" then
        UpdateIcon()
    end
end)
