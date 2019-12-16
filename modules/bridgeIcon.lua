module 'chatBridge.bridgeIcon'

local chatBridge = require 'chatBridge'
local hooks = {}
local pattern = '|Hplayer:Saucebot%S+%s%[(%w+)%]:%s(.+)'
local replacement = '|TInterface\\AddOns\\!chatBridge\\icon:0|t |Hplayer:%1|h[%1]|h: %2' 

function addMessage(self, text, ...)
    text = string.gsub(text, pattern, replacement)
    --text = string.gsub(text, '\124', '\124\124')
    -- (|Hplayer:([^:]+).-|h.-|h)
    -- |Hplayer:Saucebot:307:GUILD|h[|cffc69b6dSaucebot|r]|h: [Evion]: aaaaaaaaaaaaa
    -- |Hplayer:Saucebot:307:GUILD|h[Saucebot]|h: [Evion]: aaaaaaaaaaaaa
    -- |Hplayer:Saucebot[^%S]
    hooks[self].AddMessage(self, text, ...)
end

for i = 1, _G.NUM_CHAT_WINDOWS do
	if i ~= 2 then -- skip combat log
		local chatFrame = _G['ChatFrame' .. i]
		hooks[chatFrame] = hooks[chatFrame] or {}
		hooks[chatFrame].AddMessage = chatFrame.AddMessage
		chatFrame.AddMessage = addMessage
	end
end

-- chatter support
chatBridge.addjob(function()
    if not _G.Chatter then
        return false
    end
    
    hooks['chatter'] = Chatter:GetModule("Player Class Colors").AddMessage

    Chatter:GetModule("Player Class Colors").AddMessage = function(self, frame, text, ...)
        if text and type(text) == "string" then 
            text = string.gsub(text, pattern, replacement)
        end
        hooks['chatter'](self, frame, text, ...)
    end
    
    print('chatter hooked')
    return true
end)