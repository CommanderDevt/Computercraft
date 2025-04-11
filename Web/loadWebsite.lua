local modem = peripheral.find("modem")
TargetDomain = {...}
TargetDomain = TargetDomain[1]
local replyChannel = math.random(0,65535)
modem.open(replyChannel)
modem.transmit(121,replyChannel,TargetDomain)

local event, side, channel, r, message, distance
repeat
  event, side, channel, r, message, distance = os.pullEvent("modem_message")
until channel == replyChannel and message ~= nil
local content = message
local CMLParser = loadfile("CMLParser.lua")
CMLParser(content)
