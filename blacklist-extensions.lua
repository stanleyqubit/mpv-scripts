opts = {
    blacklist="",
    whitelist="",
    remove_file_without_extension = false,
    oneshot = true,
}
(require 'mp.options').read_options(opts)
local utils = require 'mp.utils'

function split(input)
    local ret = {}
    for str in string.gmatch(input, "([^,]+)") do
        ret[#ret + 1] = str
    end
    return ret
end

opts.blacklist = split(opts.blacklist)
opts.whitelist = split(opts.whitelist)

local filter
if #opts.whitelist > 0 then
    filter = function(extension)
        for _, ext in pairs(opts.whitelist) do
            if extension == ext then
                return false
            end
        end
        return true
    end
elseif #opts.blacklist > 0 then
    filter = function(extension)
        for _, ext in pairs(opts.blacklist) do
            if extension == ext then
                return true
            end
        end
        return false
    end
else
    return
end

function process(playlist_count)
    if playlist_count < 2 then return end
    if opts.oneshot then
        mp.unobserve_property(observe)
    end
    local playlist = mp.get_property_native("playlist")
    for i = #playlist, 1, -1 do
        local filename = playlist[i].filename
        local extension = string.match(filename, "%.([^.]+)$")
        if (opts.remove_file_without_extension and not extension)
            or filter(string.lower(extension))
        then
            mp.commandv("playlist-remove", i-1)
        end
    end
end

function observe(k,v) process(v) end

mp.observe_property("playlist-count", "number", observe)