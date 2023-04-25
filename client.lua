--[[

-- IF YOU ARE USING A TEST ENVIROMENT YOU WILL NEED TO IMPLEMENT A CUSTOM GETGENV

function getgenv()
    local genv = {}
    local genvMeta = {
        __index = function(_, key)
            return _G[key]
        end,
        __newindex = function(_, key, value)
            _G[key] = value
        end,
        __metatable = false
    }
    setmetatable(genv, genvMeta)
    return genv
end

]]

getgenv().Key = "123123" -- Valid key is "hacker"


local Key = getgenv().Key or ""

getgenv().SavedKey = Key

local seed = os.time()
local initialClock = os.clock()
local initialTime = os.time()

function customFloor(x)
    return x >= 0 and math.floor(x) or math.ceil(x)
end

function encryptString(str, key)
    local result = ""
    local keyLength = #key
    for i = 1, #str do
        local charCode = string.byte(str, i)
        local keyChar = string.byte(key, i % keyLength + 1)
        local xorResult = customXOR(charCode, keyChar)
        result = result .. string.char(xorResult)
    end
    return result
end

function decryptString(str, key)
    local result = ""
    local keyLength = #key
    for i = 1, #str do
        local charCode = string.byte(str, i)
        local keyChar = string.byte(key, i % keyLength + 1)
        local xorResult = customXOR(charCode, keyChar)
        result = result .. string.char(xorResult)
    end
    return result
end

function customXOR(a, b)
    local result = 0
    local bitValue = 1
    for i = 0, 7 do
        local bitA = a % 2
        local bitB = b % 2
        if (bitA + bitB) % 2 == 1 then
            result = result + bitValue
        end
        a = customFloor(a / 2)
        b = customFloor(b / 2)
        bitValue = bitValue * 2
    end
    return result
end

function Random()
    local a = 1103515245
    local c = 12345
    local m = 2^31

    seed = (a * seed + c) % m

    return seed / m
end

local function Crash()
    while true do end
end

function RandomSeed(newSeed)
    seed = newSeed or os.time()
end

function customRandomInt(min, max)
    min = math.floor(min)
    max = math.floor(max)
    return math.floor(Random() * (max - min + 1)) + min
end

function checkSameSeed()
    local currentSeed = os.time()

    if currentSeed == seed then
        print("Warning: Potential spoofing detected! 0X01")
        Crash()
    end
end

function checkSpoofing()
    local currentTime = os.time()
    local elapsedTime = os.clock() - initialClock
    local equationResult = currentTime * elapsedTime / initialTime

    if equationResult<=0 then 
        print("Warning: Potential spoofing detected! 0X02")
        Crash()
        
    end

end

local function valueExists(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

local function Load()

    RandomSeed(seed + 139842319) -- 139842319 is a secret number.

    checkSameSeed()
    checkSpoofing()

    local RTBL = {
        Randoms = {
            Random(), Random(), Random(), Random()
        },
        Ints = {
            customRandomInt(4,10), customRandomInt(4,10), customRandomInt(2,15),customRandomInt(2,15)
        }
    }

    local Funcs = {
        math.random,
        string.sub,
        string.byte,
        os.date,
        os.time,
        setfenv
    }

    for _, v in ipairs(RTBL.Randoms) do
        if valueExists(RTBL.Ints, v) then
            print("S1")
            Crash()
        end
    end
    
    for _, v in ipairs(RTBL.Ints) do
        if valueExists(RTBL.Randoms, v) then
            print("S2")
            Crash()
        end
    end

    if (RTBL.Randoms[1] == RTBL.Randoms[2] or RTBL.Randoms[3] == RTBL.Randoms[4]) then
        print("R")
        Crash()
    end

    for i = 1, #Funcs do
        if (iscclosure(Funcs[i])) or  (pcall(setfenv, Funcs[i], {})) then
            Crash()
        end
    end

    if (1 + 1 ~= 2) or (2 + 2 ~= 4) then
        Crash()
    end

    if getgenv().Key ~= getgenv().SavedKey then 
        print("S3")
        Crash()
    end

    if encryptString(getgenv().Key, tostring(customRandomInt(1,customRandomInt(1,1000)))) == encryptString(getgenv().Key, tostring(customRandomInt(1,customRandomInt(1000,5000)))) then
        print("S4")
        Crash()
    end

    return {true,false,true,getgenv().Key,true}

end

if (Load()[1] == true) and (Load()[1] == not false) and (Load()[2] == false)  and (Load()[2] == not true) and (Load()[4] == Key) and (Key == Load()[4] or getgenv().Key) and (Load()[2+3] == not false) and (Load()[1+4] == true) and Key == "hacker" then 
    print("Whitelisted!")
else
    return;
end
