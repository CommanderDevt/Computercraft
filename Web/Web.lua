local modem = peripheral.find("modem")
modem.open(121) -- for viewing&loading websites
modem.open(12121) -- for creating and modifying stuff

local sha256 = loadfile("sha.lua")
function tableFind(table,str)
    for _,value in ipairs(table) do
        if value == str then
            return true
        end
    end
    return false
end

function viewWebsite(replyChannel,message)
    local strdot = nil
    for c = 1, #message do
        local char = message:sub(c, c)
        if char == "." then
            strdot = c
        end
    end
    local slash = string.find(message,"/")

    if strdot == nil then return end
    local tld = nil
    local subpage = nil
    if slash == nil then
        tld = message:sub(strdot + 1, #message)
    else
        subpage = message:sub(slash+1,#message)
        tld = message:sub(strdot + 1, slash-1)
        print(strdot+1,slash-1)
    end
    local domainName = message:sub(1, strdot - 1)

    -- find CML file
    local CMLFileName = nil
    if subpage == nil then
        CMLFileName = domainName
    else
        CMLFileName = subpage
    end
    local path = "TopLevelDomains/" .. string.upper(tld) .. "/websites/" .. domainName
    local cmlFilePath = path .. "/CML/" .. CMLFileName .. ".cml"

    if fs.exists(cmlFilePath) then
        print("file exists")
        local file = fs.open(cmlFilePath, "r")
        local content = file.readAll()
        file.close()
        modem.transmit(replyChannel, 121, content)
    else
        print(cmlFilePath,"Doesnt exist")
    end
end

function loginAccount(message)
    local username, password = message:match("~([^~]+)~([^~]+)~")
    if fs.exists("Accounts/"..username..".json") then
        local file = fs.open("Accounts/"..username..".json","r")
        local content = file.readAll()
        file.close()
        content = textutils.unserializeJSON(content)
        local hash = sha256(password)
        if username == content.username and hash == content.password then
            return true
        end
    else
        return false
    end
end

function registerAccount(replyChannel,message)
    local allowedChars = {
        "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
        "!","$","#","^","&","*","_"
    }

    local username, password = message:match("~([^~]+)~([^~]+)~")
    local success = true
    --validate username&password
    for c=1,#username do
        local char = username:sub(c,c)
        if tableFind(allowedChars,string.lower(char)) == false then
            success = false
            return {success = success,error="Invalid Username"}
        end
    end
    for c=1,#password do
        local char = password:sub(c,c)
        if tableFind(allowedChars,string.lower(char)) == false then
            success = false
            return {success = success,error="Invalid Password"}
        end
    end
    if fs.exists("Accounts/"..username) == true then
        success = false
        return {success = success,error="Account already exists"}
    end
    local hash = sha256(password)
    local file = fs.open("Accounts/"..username..".json","w")
    local data = {
        ["username"]=username,
        ["password"]=hash
    }
    file.write(textutils.serializeJSON(data))
    file.close()
    return true
end

function registerWebsite(replyChannel,message)
    --RW~username~password~!~domainName~tld~--
    message = message:sub(3,#message)
    local findExc = string.find(message,"!")
    local login = message:sub(1,findExc-1)
    local username, password = login:match("~([^~]+)~([^~]+)~")
    local domaintld = message:sub(findExc+1,#message)
    local domainName,tld = domaintld:match("~([^~]+)~([^~]+)~")
    local validAccount = loginAccount(login)
    if validAccount == false then
        return {success = false,error = "Invalid account credentials or account doesnt exist."}
    end
    if fs.exists("TopLevelDomains/"..string.upper(tld)) == false then
        return {success = false,error = "Top-Level-Domain does not exist."}
    end
    if fs.exists("TopLevelDomains/"..string.upper(tld).."/websites/"..domainName) == true then
        return {success = false,error = "Domain is taken."}
    else
        local path = "TopLevelDomains/"..string.upper(tld).."/websites/"..domainName
        fs.makeDir(path.."/CML")
        local data = fs.open(path.."/data.json","w")
        local dataJSON = {
            owner = username,
            name = domainName,
            path = domainName.."."..string.lower(tld),
            balance = 0
        }
        dataJSON = textutils.serializeJSON(dataJSON)
        data.write(dataJSON)
        data.close()
        cml = fs.open(path.."/CML/"..domainName..".cml","w")
        cml.write(string.format("<t~>%s</t~>",domainName))
        cml.close()
        return {success=true}
    end
end

function modifyWebsite(replyChannel,message)
    message = message:sub(3,#message)
    local findExc = string.find(message,"!")
    local login = message:sub(1,findExc-1)
    local username, password = login:match("~([^~]+)~([^~]+)~")
    local find2Exc = string.find(message,"!",findExc+1)
    local domaintld = message:sub(findExc+1,find2Exc-1)
    local domainName,tld = domaintld:match("~([^~]+)~([^~]+)~")
    local CMLFilename  = message:sub(find2Exc+1,#message)
    local find3Exc = string.find(message,"!",find2Exc+1)
    local CML = message:sub(find3Exc+1,#message)
    local validAccount = loginAccount(login)
    if validAccount == false then
        return {success = false,error = "Invalid account credentials or account doesnt exist."}
    end
    local path = "TopLevelDomains/"..string.upper(tld).."/websites/"..domainName
    if fs.exists(path) == true == true then
        local websitedatafile = fs.open(path.."/data.json","r")
        local websitedata = websitedatafile.readAll()
        websitedata = textutils.unserializeJSON(websitedata)
        websitedatafile.close()
        if websitedata.owner == username then
            local file = fs.open(path.."/CML/"..CMLFilename..".cml","w")
            file.write(CML)
            file.close()
            return {success = true}
        else
            return {success = false,error = "Account does not own this website."}
        end
    end
end

-- print(registerAccount(0,"~Commander~CMD~"))
-- print(loginAccount(0,"~Commander~CMD~"))

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    
    if message ~= nil and message ~= "" then
        if channel == 121 then
            viewWebsite(replyChannel,message)
        elseif channel == 12121 then
            if message:sub(1,2) == "RW" then
                registerWebsite(replyChannel,message)
            elseif message:sub(1,2) == "RA" then
                registerAccount(replyChannel,message)
            elseif message:sub(1,2) == "MW" then
                modifyWebsite(replyChannel,message)
            end
        end
    end

    sleep(0)
end
