local WebId = 4

peripheral.find("modem",rednet.open)

Expressions["get"] = function(domain)
    rednet.send(WebId,"",domain.."~GET")
    local f = function()
        local id,msg rednet.receive(domain.."~RESPONSE")
        if id == WebId then
            return msg
        end
    end
    local c = coroutine.create(f)
    local success,result = coroutine.resume(c)
    return result
end
