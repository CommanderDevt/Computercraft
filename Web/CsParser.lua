local content = ...

function trim(s)
    return s:match("^%s*(.-)%s*$")
end

function split(input, delimiter)
    local result = {}
    for part in string.gmatch(input, "[^" .. delimiter .. "]+") do
        table.insert(result, part)
    end
    return result
end

function ParseText(s)
    if s:sub(1,1) == "|" and s:sub(#s,#s) == "|" then
        return tonumber(s:sub(2,#s-1))
    elseif s:sub(1,1) == "'" and s:sub(#s,#s) == "'" then
        return tostring(s:sub(2,#s-1))
    end
end

local RVars = {}

local Expressions = {
    ["plus"] = function(v1,v2)
        v1 = tonumber(v1)
        v2 = tonumber(v2)
        return tostring(v1+v2)
    end,
    ["equals"] = function(v1,v2)
        return tostring(v1==v2)
    end,
    ["more"] = function(v1,v2)
        v1 = tonumber(v1)
        v2 = tonumber(v2)
        return tostring(v1>v2)
    end,
    ["less"] = function(v1,v2)
        v1 = tonumber(v1)
        v2 = tonumber(v2)
        return tostring(v1<v2)
    end,
    ["moreequal"] = function(v1,v2)
        v1 = tonumber(v1)
        v2 = tonumber(v2)
        return tostring(v1>=v2)
    end,
    ["lessequal"] = function(v1,v2)
        v1 = tonumber(v1)
        v2 = tonumber(v2)
        return tostring(v1<=v2)
    end,
    ["not"] = function(v1)
        if v1 == "true" then return "false" elseif v1 == "false" then return "true" end
    end,
    ["minus"] = function(v1,v2)
        v1 = tonumber(v1)
        v2 = tonumber(v2)
        return tostring(v1-v2)
    end,
    ["multiply"] = function(v1,v2)
        v1 = tonumber(v1)
        v2 = tonumber(v2)
        return tostring(v1*v2)
    end,
    ["divide"] = function(v1,v2)
        v1 = tonumber(v1)
        v2 = tonumber(v2)
        return tostring(v1/v2)
    end,
    ["modulus"] = function(v1,v2)
        v1 = tonumber(v1)
        v2 = tonumber(v2)
        return tostring(v1%v2)
    end,
    ["exponent"] = function(v1,v2)
        v1 = tonumber(v1)
        v2 = tonumber(v2)
        return tostring(v1^v2)
    end,
    ["second"] = function()
        local currentTime = os.time()
        currentTime=currentTime*60
        local fractionalPart = currentTime % 1.2
        local currentSecond = math.floor((fractionalPart / 0.020) % 60)
        return currentSecond
    end,
    ["minute"] = function()
        local currentTime = os.time()
        local mfractionalPart = currentTime/60
        local currentMinute = math.floor((mfractionalPart / 0.020)%60)
        return currentMinute
    end,
    ["hour"] = function()
        local currentTime = os.time()
        local hfractionalPart = currentTime/3600
        local currentHour = math.floor((hfractionalPart / 0.020)%24)
        return currentHour
    end
}
Expressions.same = Expressions.equals

local Functions = {}

function InverseSub(s,v,i,x)
    local bs = s:sub(1,i-1)
    local as = s:sub(x+1,#s)
    return bs..v..as
end

function ParseExpression(expression)
    local s = expression:sub(2,#expression-1)
    local ovalues = split(s,",")
    local express = ovalues[1]
    table.remove(ovalues,1)
    local values = {}
    for i=1,#ovalues do
        values[i] = ParseText(ovalues[i])
    end
    if Expressions[express] then
        return Expressions[express](table.unpack(values))
    else
        return "'ERROR'"
    end
end

function magiclines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

-- Forward declaration
local executeCode

local Actions = {
    ["set"] = function(text)
        local space = string.find(text," ")
        local varName = text:sub(1,space-1)
        local symb = string.find(text,"'",space+1) or string.find(text,'"',space+1)
        if symb and space then
            local symb2 = string.find(text,"'",symb+1) or string.find(text,'"',symb+1)
            if not symb2 then return end
            --Value is a string
            local value = text:sub(symb+1,symb2-1)
            value = tostring(value)
            RVars[varName] = "'"..value.."'"
        elseif space then
            --Value is a number
            local value = text:sub(space+1,#text-1)
            value = tostring(value)
            RVars[varName] = "|"..value.."|"
        end
    end,
    ["print"] = function(text)
        print(text)
    end,
    ["call"] = function(text)
        -- functionName is text
        text = trim(text)
        if Functions[text] then
            executeCode(Functions[text].Code)
        else
            print("Function " .. text .. " not found")
        end
    end,
    ["wait"] = function(text)
        text = tonumber(trim(text))
        if text == nil then print("INVALID TIME") return end
        sleep(text)
    end
}

local Questions = {
-- Add this to your Questions table
["if"] = function(text,line,i,lines)
    local trimmed = trim(text)
    local trcolon = trimmed:find(":")
    local colonS, colonE = text:find(" : ")
    local value = trimmed:sub(1, trcolon-2)
    local code = trim(text:sub(colonE+1, #text))
    
    if value == "true" or value == true then
        if code == "!sequence" then
            local sequenceCode = ""
            local j = i + 1
            
            -- Collect sequence body
            while j <= #lines and lines[j] and lines[j]:sub(1, 1) == "-" do
                sequenceCode = sequenceCode .. lines[j]:sub(2) .. "\n"
                j = j + 1
            end
            
            -- Immediately execute the sequence code
            executeCode(sequenceCode)
        else
            executeCode(code)
        end
    end
    return false
end
}

function collectFunctions(lines)
    local i = 1
    while i <= #lines do
        local line = lines[i]
        
        -- Check if this is a function declaration
        if line:sub(1, 5) == "!func" then
            local functionName = trim(line:sub(7))
            local functionCode = ""
            local j = i + 1
            
            -- Collect function body until we reach a line that doesn't start with "-"
            while j <= #lines and lines[j]:sub(1, 1) == "-" do
                -- Remove the leading hyphen and add to function code
                functionCode = functionCode .. lines[j]:sub(2) .. "\n"
                j = j + 1
            end
            
            -- Register the function
            Functions[functionName] = {
                StartIndex = i,
                Code = functionCode
            }
            
            i = j -- Skip to after the function body
        else
            i = i + 1
        end
    end
end

function executeCode(code)
    local lines = {}
    for line in magiclines(code) do
        table.insert(lines, line)
    end
    
    -- First pass: collect all function definitions
    collectFunctions(lines)
    
    -- Second pass: execute the code
    local i = 1
    while i <= #lines do
        local line = lines[i]
        
        -- Skip function declarations and their bodies
        if line:sub(1, 5) == "!func" then
            -- Skip until we find a line that doesn't start with "-"
            while i < #lines and lines[i+1] and lines[i+1]:sub(1, 1) == "-" do
                i = i + 1
            end
        -- Handle sequences - immediately execute the block
        elseif line:sub(1, 9) == "!sequence" then
            local sequenceCode = ""
            local j = i + 1
            
            -- Collect sequence body
            while j <= #lines and lines[j] and lines[j]:sub(1, 1) == "-" do
                sequenceCode = sequenceCode .. lines[j]:sub(2) .. "\n"
                j = j + 1
            end
            
            -- Immediately execute the sequence code
            executeCode(sequenceCode)
            
            i = j - 1 -- Skip to the end of sequence body
        else
            -- Process variables
            local newText = line
            local Init = 1
            repeat
                local startBrace = newText:find("{", Init)
                if startBrace then
                    Init = startBrace
                    local endBrace = newText:find("}", Init)
                    if endBrace then
                        Init = endBrace
                        local varName = newText:sub(startBrace + 1, endBrace - 1)
                        if RVars[varName] then
                            local diff = #newText
                            newText = InverseSub(newText, ParseText(RVars[varName]), startBrace, endBrace)
                            diff = #newText-diff
                            Init = Init + diff
                        end
                    else
                        print("Malformed Variable")
                        break
                    end
                end
            until startBrace == nil
            
            -- Process expressions
            Init = 1
            repeat
                local startBrace = newText:find("%[", Init)
                if startBrace then
                    Init = startBrace 
                    local endBrace = newText:find("%]", Init)
                    if endBrace then
                        Init = endBrace
                        local diff = #newText
                        newText = InverseSub(newText, ParseExpression(newText:sub(startBrace, endBrace)), startBrace, endBrace)
                        diff = #newText-diff
                        Init = Init + diff
                    else
                        print("Malformed Expression")
                        break
                    end
                end
            until startBrace == nil
            
            -- Process actions
            if newText:sub(1, 1) == "!" then
                local space = newText:find(" ", 1)
                if space then
                    local actionName = newText:sub(2, space - 1)
                    local actionParam = newText:sub(space + 1)
                    
                    if actionName ~= "func" and actionName ~= "sequence" and Actions[actionName] then
                        Actions[actionName](actionParam)
                    end
                end
            elseif newText:sub(1, 1) == "?" then
                local space = newText:find(" ", 1)
                if space then
                    local actionName = newText:sub(2, space - 1)
                    local actionParam = newText:sub(space + 1)
                    local result = Questions[actionName](actionParam,newText,i,lines)
                    if result == true then
                        local colonS,colonE = actionParam:find(" : ")
                        executeCode(actionParam:sub(colonE+1,#newText))
                    end
                end
            end
        end
        
        i = i + 1
    end
end

function csParse(lineIterator)
    local fullCode = ""
    for line in lineIterator do
        fullCode = fullCode .. line .. "\n"
    end
    
    executeCode(fullCode)
end

csParse(magiclines(content))
