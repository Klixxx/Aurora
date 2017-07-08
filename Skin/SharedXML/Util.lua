local _, private = ...

-- [[ Lua Globals ]]
local next = _G.next
local assert, type, pcall = _G.assert, _G.type, _G.pcall

do --[[ CUSTOM_CLASS_COLORS ]]--
    local classColors = {}

    local callbacks, numCallbacks = {}, 0
    function classColors:RegisterCallback(method, handler)
        --print("CUSTOM_CLASS_COLORS:RegisterCallback", method, handler)
        assert(type(method) == "string" or type(method) == "function", "Bad argument #1 to :RegisterCallback (string or function expected)")
        if type(method) == "string" then
            assert(type(handler) == "table", "Bad argument #2 to :RegisterCallback (table expected)")
            assert(type(handler[method]) == "function", "Bad argument #1 to :RegisterCallback (method \"" .. method .. "\" not found)")
            method = handler[method]
        end
        -- assert(not callbacks[method] "Callback already registered!")
        callbacks[method] = handler or true
        numCallbacks = numCallbacks + 1
    end
    function classColors:UnregisterCallback(method, handler)
        --print("CUSTOM_CLASS_COLORS:UnregisterCallback", method, handler)
        assert(type(method) == "string" or type(method) == "function", "Bad argument #1 to :UnregisterCallback (string or function expected)")
        if type(method) == "string" then
            assert(type(handler) == "table", "Bad argument #2 to :UnregisterCallback (table expected)")
            assert(type(handler[method]) == "function", "Bad argument #1 to :UnregisterCallback (method \"" .. method .. "\" not found)")
            method = handler[method]
        end
        -- assert(callbacks[method], "Callback not registered!")
        callbacks[method] = nil
        numCallbacks = numCallbacks - 1
    end
    local function DispatchCallbacks()
        if numCallbacks < 1 then return end
        --print("CUSTOM_CLASS_COLORS:DispatchCallbacks")
        for method, handler in next, callbacks do
            local ok, err = pcall(method, handler ~= true and handler or nil)
            if not ok then
                _G.print("ERROR:", err)
            end
        end
    end

    function classColors:NotifyChanges()
        if not private.classColorsHaveChanged then
            -- We can't determine if the colors have changed, dispatch just in case.
            DispatchCallbacks()
        elseif private.classColorsHaveChanged() then
            DispatchCallbacks()
        end
    end

    local classTokens = {}
    for token, class in next, _G.LOCALIZED_CLASS_NAMES_MALE do
        classTokens[class] = token
    end
    for token, class in next, _G.LOCALIZED_CLASS_NAMES_FEMALE do
        classTokens[class] = token
    end
    function classColors:GetClassToken(className)
        return className and classTokens[className]
    end

    function private.classColorsReset(colors)
        colors = colors or _G.CUSTOM_CLASS_COLORS
        for class, color in next, _G.RAID_CLASS_COLORS do
            colors[class] = {
                r = color.r,
                g = color.g,
                b = color.b,
                colorStr = color.colorStr
            }
        end

        if colors then
            classColors:NotifyChanges()
        else
            DispatchCallbacks()
        end
    end

    _G.CUSTOM_CLASS_COLORS = {}

    _G.setmetatable(_G.CUSTOM_CLASS_COLORS, {__index = classColors})
end

function private.SharedXML.Util()
    if private.classColorsInit then
        private.classColorsInit()
    else
        private.classColorsReset()
    end

    if not private.highlightColor.r then
        local _, class = _G.UnitClass("player")
        local color = _G.CUSTOM_CLASS_COLORS[class]
        private.highlightColor:SetRGB(color.r, color.g, color.b)
    end
end
