module 'chatBridge'

local frame = CreateFrame('Frame')
jobs = {}
hooks = {}

function M.sethook(k, v)
    hooks[k] = v
end

function M.gethook(k)
    return hooks[k]
end

frame:SetScript('OnEvent', function()
	this[event](this)
end)

function M.print(arg)
	DEFAULT_CHAT_FRAME:AddMessage(LIGHTYELLOW_FONT_COLOR_CODE .. '<chatBridge> ' .. tostring(arg), ' ')
end

function M.tokenize(str)
	local tokens = {}
	for token in string.gmatch(str, '%S+') do tinsert(tokens, token) end
	return tokens
end

function M.size(t)
	local size = 0
	for _ in pairs(t) do
		size = size + 1
	end
	return size
end

function M.addjob(f, args)
    table.insert(jobs, {task=f, args=args})
    
    if not frame:IsShown() then
        frame.elapsed = 0
        frame:Show()
    end
end

function frame:Lazyload()
    if #jobs == 0 then
        return
    end
    
    for key, job in ipairs(jobs) do
        if job.done then
            table.remove(jobs, key)
        end
    end
    
    for key, job in ipairs(jobs) do
        job.done = job.task(job.args)
    end
end

local PrintDebug = function() end

frame.elapsed = 0
frame:SetScript('OnUpdate', function(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    
    self:Lazyload()
    
    if this.elapsed > 3 then
        self.elapsed = 0
        this:Hide()
    end
end)