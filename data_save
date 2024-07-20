function write_data(data, name)
    if not fs.exists('/data') then
        fs.makeDir('/data')
    end
    local f = fs.open('/data/'..name, 'w')
    f.write(textutils.serialize(data))
    f.close()
end
 
function read_data(name)
    if fs.exists('/data/'..name) then
        local f = fs.open('/data/'..name, 'r')
        data = textutils.unserialize(f.readAll())
        f.close()
    end
    return data
end
