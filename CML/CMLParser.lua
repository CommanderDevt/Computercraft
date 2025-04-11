local content = ...
local viewWebsite = loadfile("viewWebsite.lua")
local elements = {}
local Settings = {
    Title = "my website",
    Icon = "@",
    Default_textbgcolor = "f",
    Default_textcolor = "0",
    Bgcolor = "f"
    }
    
    local CCCToColor = {
        ["0"] = colors.white,
        ["1"] = colors.orange,
        ["2"] = colors.magenta,
        ["3"] = colors.lightBlue,
        ["4"] = colors.yellow,
        ["5"] = colors.lime,
        ["6"] = colors.pink,
        ["7"] = colors.gray,
        ["8"] = colors.lightGray,
        ["9"] = colors.cyan,
        ["a"] = colors.purple,
        ["b"] = colors.blue,
        ["c"] = colors.brown,
        ["d"] = colors.green,
        ["e"] = colors.red,
        ["f"] = colors.black
    }
    
    local CursorPosM = {
        x = 1,
        y = 1,
    }
    
    term.setBackgroundColor(CCCToColor[Settings.Bgcolor:sub(1,1)])
    term.clear()
    term.setCursorPos(1,1)
    
    function render(Data)
        local function TagName(Tag)
            Tag = Tag:gsub("<","")
            Tag = Tag:gsub(">","")
            Tag = Tag:gsub("/","")
            local str,endd = Tag:find("~")
            return Tag:sub(1,endd-1)
        end
    
        local function IterateAttributes(Tag)
            local Attributes = {}
            Tag = Tag:gsub(">","")
            local TagMain = Tag:find("~")
            Tag = Tag:sub(TagMain+1,#Tag)
            Tag = Tag:gsub(" ","")
            local AttrStartIndex = 1
            local TagLeft = Tag
            local i = 0
            repeat
                i = i + 1
                local char = TagLeft:sub(1,1)
                if char == "," then
                    local str = Tag:sub(AttrStartIndex,i-1)
                    local start,endd = string.find(str,"=")
                    Attributes[str:sub(1,endd-1)] = str:sub(endd+1,#str)
                    AttrStartIndex = i+1
                end
                if #TagLeft == 1 then
                    local str = Tag:sub(AttrStartIndex,i)
                    if str ~= "" then
                        local start,endd = string.find(str,"=")
                        Attributes[str:sub(1,endd-1)] = str:sub(endd+1,#str)
                    end
                end
                TagLeft = TagLeft:sub(2,#TagLeft)
            until #TagLeft == 0
            return Attributes
        end
    
        local STagName = TagName(Data.STag)
        local ETagName = TagName(Data.ETag)
        if STagName ~= ETagName then
            print("ERROR: Start tag name and End tag name do not match.")
            return
        end
    
        if STagName == "t" then
            local x, y = term.getCursorPos()
            local Attributes = {
                color = Settings.Default_textcolor,
                bgcolor = Settings.Default_textbgcolor,
                x = x,
                y = y
            }
            local AttrChanged = {}
            local Attr = IterateAttributes(Data.STag)
            for index, value in pairs(Attr) do
                AttrChanged[index] = true
                Attributes[index] = value
            end
    
            Attributes.x = tonumber(Attributes.x)
            Attributes.y = tonumber(Attributes.y)
            x = Attributes.x
            y = Attributes.y
    
            -- Split the text into lines using the new line character
            local lines = {}
            for line in Data.Text:gmatch("[^\n]*") do
                if line ~= "" then
                    table.insert(lines, line)
                else
                    table.insert(lines,"") 
                end
            end
            if AttrChanged.x then
                CursorPosM.x = Attributes.x
            end
            -- Render each line
            for l, line in ipairs(lines) do
                if l == 1 then
                    if AttrChanged.x then
                        term.setCursorPos(Attributes.x,y)
                    end
                    x,y = term:getCursorPos()
                    if AttrChanged.y then
                        term.setCursorPos(x,Attributes.y)
                    end
                else
                    term.setCursorPos(CursorPosM.x-1, y + l - 1)
                end
                strx,stry = term:getCursorPos()
                term.blit(line,
                    (Attributes.color:sub(1, 1)):rep(#line),  -- Color for this line
                    (Attributes.bgcolor:sub(1, 1)):rep(#line)  -- Background color for this line
                )
                endx,endy = term:getCursorPos()
                local element = {type = STagName,startXPos=strx,endXPos=endx,y=stry,Attributes=Attributes}
                table.insert(elements,element)
            end
        elseif STagName == "config" then
            local Attributes = Settings
            local Attr = IterateAttributes(Data.STag)
            local Changed = {}
            for index, value in pairs(Attr) do
                Changed[index] = true
                Attributes[index] = value
            end
            Settings = Attributes
            if Changed.Bgcolor == true then
                term.setBackgroundColor(CCCToColor[Settings.Bgcolor:sub(1,1)])
                term.clear()
                term.setCursorPos(1,1)
            end
        end
    end
    local pattern = "(<[^>]+>)(.-)(</[^>]+>)"
    
    for STag, rawText, ETag in content:gmatch(pattern) do
        -- Replace '\\n' with actual newline character
        local Text = rawText:gsub("\\n", "\n")
        render({ STag = STag, Text = Text, ETag = ETag })
    end
    
function handleClick(x,y)
    for _,element in ipairs(elements) do
        if element.Attributes.link then
            local link = element.Attributes.link
            local strX = element.startXPos
            local endX = element.endXPos
            local ey = element.y
            if ey == y and strx <= x and endx >= x then
                --link clicked
                viewWebsite(link)
            end
        end
    end
end

    while true do
        local event, button, x, y = os.pullEvent("mouse_click")
        if button == 1 then
            handleClick(x,y)
        end
    end
    
