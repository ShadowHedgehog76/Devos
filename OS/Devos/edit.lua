-- Get file to edit
local args = {...}
local original = shell.resolveProgram(args[1]) or args[1]
if original:sub(1, 1) ~= "/" then
	original = "/" .. original
end

local x, y, names, lines, paths, dirs, positions, openPosition, opened, scrollX, scrollY, readOnly = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
local w, h = term.getSize()
local current
local menuHeight = 1
local lineNumLen

local running = true

-- Colors
--Code
local bgColor = colors.black
local textColor = colors.white
local keywordColor = colors.blue
local commentColor = colors.green
local stringColor = colors.orange
local numberColor = colors.green
local functionColor = colors.cyan
local varColor = colors.purple

--Menus
local menuTextcolor = colors.white
local selectedColor = colors.lightBlue
local unselectedColor = colors.lightGray
local lineNumColor = colors.white
local menuBgColor = colors.gray
local openColor = colors.green
local closeColor = colors.red
local readOnlyColor = colors.yellow


-- Menus
local menu = false
local menuItem = 1
local menuItems = {"Save", "Exit", "Run"}
	
local status = "Press Ctrl to access menu"
if string.len(status) > w - 5 then
	status = "Press Ctrl for menu"
end

local function load(_path)
	temp = {}
	if fs.exists(_path) then
		local file = io.open(_path, "r")
		local line = file:read()
		while line do
			table.insert(temp, line)
			line = file:read()
		end
		file:close()
	end
	
	if #temp == 0 then
		table.insert(temp, "")
	end
	
	return temp
end

local function save(path)
	if not readOnly[path] then
		if not fs.exists(dirs[path]) then
			fs.makeDir(dirs[path])
		end

		local file = nil
		local function innerSave()
			file = fs.open(path, "w")
			if file then
				for n, line in ipairs(lines[path]) do
					file.write(line .. "\n")
				end
			else
				error("Failed to open "..path)
			end
		end
		
		local ok = pcall(innerSave)
		if file then 
			file.close()
		end
		return ok
	end
end

local function open(path)
	local name
	
	path = shell.resolveProgram(path) or path
	if path:sub(1, 1) ~= "/" then
		path = "/" .. path
	end
	name = string.gsub(path, "^.*/(.-)$", "%1")
	
	if opened[path] then
		current = path
		return
	end
	lines[path] = load(path)
	
	current = path
	names[path] = name
	paths[name] = path
	dirs[path] = path:sub(1, path:len() - name:len())
	opened[path] = true
	x[path] = 1
	y[path] = 1
	scrollX[path] = 0
	scrollY[path] = 0
	readOnly[path] = fs.isReadOnly(path)
end

local function close(path)
	if current == original then
		for k, _ in pairs(opened) do
			original = k
			break
		end
	end
	
	save(path)
	paths[names[path]] = nil
	dirs[path] = nil
	names[path] = nil
	lines[path] = nil
	positions[path] = nil
	opened[path] = nil
	x[path] = nil
	y[path] = nil
	scrollX[path] = nil
	scrollY[path] = nil
	
	if current == path then
		current = original
	end
end

local keywords = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"]= true,
	["while"] = true,
}

local functions = {
	["bit.band"] = true, 
	["bit.blogic_rshift"] = true, 
	["bit.bnot"] = true, 
	["bit.bor"] = true, 
	["bit.brshift"] = true, 
	["bit.bxor"] = true, 
	["bit.tobits"] = true, 
	["bit.tonumb"] = true, 
	["colors.combine"] = true, 
	["colors.subtract"] = true, 
	["colors.test"] = true, 
	["commands.exec"] = true, 
	["commands.execAsync"] = true, 
	["commands.getBlockInfo"] = true, 
	["commands.getBlockPosition"] = true, 
	["commands.list"] = true, 
	["disk.eject"] = true, 
	["disk.getAudioTitle"] = true, 
	["disk.getID"] = true, 
	["disk.getLabel"] = true, 
	["disk.getMountPath"] = true, 
	["disk.hasAudio"] = true, 
	["disk.hasData"] = true, 
	["disk.isPresent"] = true, 
	["disk.playAudio"] = true, 
	["disk.setLabel"] = true, 
	["disk.stopAudio"] = true, 
	["help.completeTopic"] = true, 
	["help.lookup"] = true, 
	["help.path"] = true, 
	["help.setPath"] = true, 
	["help.topics"] = true, 
	["keys.getName"] = true, 
	["multishell.getCount"] = true, 
	["multishell.getCurrent"] = true, 
	["multishell.launch"] = true, 
	["multishell.setFocus"] = true, 
	["multishell.setTitle"] = true, 
	["multishell.getFocus"] = true, 
	["multishell.getTitle"] = true, 
	["paintutils.drawBox"] = true, 
	["paintutils.drawFilledBox"] = true, 
	["paintutils.drawImage"] = true, 
	["paintutils.drawPixel"] = true, 
	["paintutils.loadImage"] = true, 
	["parallel.waitForAll"] = true, 
	["parallel.waitForAny"] = true, 
	["rendet.broadcast"] = true, 
	["rednet.close"] = true, 
	["rednet.host"] = true, 
	["rednet.isOpen"] = true, 
	["rednet.lookup"] = true, 
	["rednet.open"] = true, 
	["rednet.receive"] = true, 
	["rednet.run"] = true, 
	["rednet.send"] = true, 
	["rednet.unhost"] = true, 
	["shell.aliases"] = true, 
	["shell.complete"] = true, 
	["shell.completeProgram"] = true, 
	["shell.clearAlias"] = true, 
	["shell.dir"] = true, 
	["shell.exit"] = true, 
	["shell.getCompletionInfo"] = true, 
	["shell.getRunningProgram"] = true, 
	["shell.openTab"] = true, 
	["shell.path"] = true, 
	["shell.programs"] = true, 
	["shell.resolve"] = true, 
	["shell.resolveProgram"] = true, 
	["shell.run"] = true, 
	["shell.setAlias"] = true, 
	["shell.setCompletionFunction"] = true, 
	["shell.setDir"] = true, 
	["shell.setPath"] = true, 
	["shell.switchTab"] = true, 
	["term.blit"] = true, 
	["term.clear"] = true, 
	["term.clearLine"] = true, 
	["term.current"] = true, 
	["term.getBackgroundColor"] = true, 
	["term.getBackgroundColour"] = true, 
	["term.getCursorPos"] = true, 
	["term.getSize"] = true, 
	["term.getTextColor"] = true, 
	["term.getTextColour"] = true, 
	["term.isColor"] = true, 
	["term.isColour"] = true, 
	["term.native"] = true, 
	["term.redirect"] = true, 
	["term.scroll"] = true, 
	["term.setBackgroundColor"] = true, 
	["term.setBackgroundColour"] = true, 
	["term.setCursorBlink"] = true, 
	["term.setCursorPos"] = true, 
	["term.setTextColor"] = true, 
	["term.setTextColour"] = true, 
	["textutils.complete"] = true, 
	["textutils.formatTime"] = true, 
	["textuitls.pagedPrint"] = true, 
	["textutils.pagedTabulate"] = true, 
	["textutils.serialize"] = true, 
	["textutils.serializeJSON"] = true, 
	["textutils.slowPrint"] = true, 
	["textutils.slowWrite"] = true, 
	["textutils.tabulate"] = true, 
	["textutils.unserialize"] = true, 
	["textutils.urlEncode"] = true, 
	["turtle.craft"] = true, 
	["turtle.forward"] = true, 
	["turtle.back"] = true, 
	["turtle.up"] = true, 
	["turtle.down"] = true, 
	["turtle.turnleft"] = true, 
	["turtle.turnRight"] = true, 
	["turtle.select"] = true, 
	["turtle.getSelectedSlot"] = true, 
	["turtle.getItemSpace"] = true, 
	["turtle.getItemDetail"] = true, 
	["turtle.equipLeft"] = true, 
	["turtle.equipRight"] = true, 
	["turtle.attack"] = true, 
	["turtle.attackUp"] = true, 
	["turtle.attackDown"] = true, 
	["turtle.dig"] = true, 
	["turtle.digUp"] = true, 
	["turtle.digDown"] = true, 
	["turtle.place"] = true, 
	["turtle.placeUp"] = true, 
	["turtle.placeDown"] = true, 
	["turtle.detect"] = true, 
	["turtle.detectUp"] = true, 
	["turtle.detectDown"] = true, 
	["turtle.inspect"] = true, 
	["turtle.inspectUp"] = true, 
	["turtle.inspectDown"] = true, 
	["turtle.compare"] = true, 
	["turtle.compareUp"] = true, 
	["turtle.compareDown"] = true, 
	["turtle.compareTo"] = true, 
	["turtle.drop"] = true, 
	["turtle.dropUp"] = true, 
	["turtle.dropDown"] = true, 
	["turtle.suck"] = true, 
	["turtle.suckUp"] = true, 
	["turtle.suckDown"] = true, 
	["turtle.refuel"] = true, 
	["turtle.getFuelLevel"] = true, 
	["turtle.getFuelLimit"] = true, 
	["turtle.transferTo"] = true, 
	["vector.new"] = true, 
	["window.create"] = true, 
	["coroutine.create"] = true, 
	["coroutine.resume"] = true, 
	["coroutine.running"] = true, 
	["coroutine.status"] = true, 
	["coroutine.wrap"] = true, 
	["coroutine.yield"] = true, 
	["fs.combine"] = true, 
	["fs.complete"] = true, 
	["fs.copy"] = true, 
	["fs.delete"] = true, 
	["fs.exists"] = true, 
	["fs.find"] = true, 
	["fs.getDrive"] = true, 
	["fs.getFreeSpace"] = true, 
	["fs.getName"] = true, 
	["fs.getSize"] = true, 
	["fs.isDir"] = true, 
	["fs.isReadOnly"] = true, 
	["fs.list"] = true, 
	["fs.makeDir"] = true, 
	["fs.move"] = true, 
	["fs.open"] = true, 
	["http.get"] = true, 
	["http.post"] = true, 
	["http.request"] = true, 
	["os.clock"] = true, 
	["os.day"] = true, 
	["os.getComputerID"] = true, 
	["os.getComputerLabel"] = true, 
	["os.pullEvent"] = true, 
	["os.pullEventRaw"] = true, 
	["os.queueEvent"] = true, 
	["os.reboot"] = true, 
	["os.run"] = true, 
	["os.setAlarm"] = true, 
	["os.setComputerLabel"] = true, 
	["os.shutdown"] = true, 
	["os.sleep"] = true, 
	["os.startTimer"] = true, 
	["os.time"] = true, 
	["os.version"] = true, 
	["peripheral.call"] = true, 
	["peripheral.find"] = true, 
	["peripheral.getMethods"] = true, 
	["peripheral.getNames"] = true, 
	["peripheral.getType"] = true, 
	["peripheral.isPresent"] = true, 
	["peripheral.wrap"] = true, 
	["print"] = true, 
	["redstone.getAnalogInput"] = true, 
	["redstone.getAnalogOutput"] = true, 
	["redstone.getBundledInput"] = true, 
	["redstone.getInput"] = true, 
	["redstone.getOutput"] = true, 
	["redstone.getSides"] = true, 
	["redstone.setAnalogOutput"] = true, 
	["redstone.setBundledOutput"] = true, 
	["redstone.setOutput"] = true, 
	["redstone.testBundledInput"] = true, 
	["tonumber"] = true, 
	["tostring"] = true, 
	["write"] = true, 
	["assert"] = true, 
	["dofile"] = true, 
	["error"] = true, 
	["getfenv"] = true, 
	["getmetatable"] = true, 
	["ipairs"] = true, 
	["loadfile"] = true, 
	["loadstring"] = true, 
	["next"] = true, 
	["pairs"] = true, 
	["pcall"] = true, 
	["rawequal"] = true, 
	["rawget"] = true, 
	["rawset"] = true, 
	["select"] = true, 
	["setfenv"] = true, 
	["setmetatable"] = true, 
	["type"] = true, 
	["unpack"] = true, 
	["xpcall"] = true, 
	["io.close"] = true, 
	["io.flush"] = true, 
	["io.input"] = true, 
	["io.lines"] = true, 
	["io.open"] = true, 
	["io.output"] = true, 
	["io.read"] = true, 
	["io.type"] = true, 
	["io.write"] = true, 
	["math.abs"] = true, 
	["math.acos"] = true, 
	["math.asin"] = true, 
	["math.atan"] = true, 
	["math.atan2"] = true, 
	["math.ceil"] = true, 
	["math.cos"] = true, 
	["math.cosh"] = true, 
	["math.deg"] = true, 
	["math.exp"] = true, 
	["math.floor"] = true, 
	["math.fmod"] = true, 
	["math.frexp"] = true, 
	["math.ldexp"] = true, 
	["math.log"] = true, 
	["math.log10"] = true, 
	["math.max"] = true, 
	["math.min"] = true, 
	["math.modf"] = true, 
	["math.rad"] = true, 
	["math.random"] = true, 
	["math.randomseed"] = true, 
	["math.sin"] = true, 
	["math.sinh"] = true, 
	["math.sqrt"] = true, 
	["math.tan"] = true, 
	["math.tanh"] = true, 
	["string.byte"] = true, 
	["string.char"] = true, 
	["string.dump"] = true, 
	["string.find"] = true, 
	["string.format"] = true, 
	["string.gmatch"] = true, 
	["string.gsub"] = true, 
	["string.len"] = true, 
	["string.lower"] = true, 
	["string.match"] = true, 
	["string.rep"] = true, 
	["string.reverse"] = true, 
	["string.sub"] = true, 
	["string.upper"] = true, 
	["table.concat"] = true, 
	["table.insert"] = true, 
	["table.maxn"] = true, 
	["table.remove"] = true, 
	["table.sort"] = true, 
	["gps.locate"] = true, 
	
}

local vars = {
	["colors.white"] = true, 
	["colors.orange"] = true, 
	["colors.magenta"] = true, 
	["colors.lightBlue"] = true, 
	["colors.yellow"] = true, 
	["colors.lime"] = true, 
	["colors.pink"] = true, 
	["colors.gray"] = true, 
	["colors.lightGray"] = true, 
	["colors.cyan"] = true, 
	["colors.purple"] = true, 
	["colors.blue"] = true, 
	["colors.brown"] = true, 
	["colors.green"] = true, 
	["colors.red"] = true, 
	["colors.black"] = true, 
	["_G"] = true, 
	["_VERSION"] = true, 
	["_CC_VERSION"] = true, 
	["_MC_VERSION"] = true, 
	["math.huge"] = true, 
	["math.pi"] = true, 
	["keys.a"] = true, 
	["keys.b"] = true, 
	["keys.c"] = true, 
	["keys.d"] = true, 
	["keys.e"] = true, 
	["keys.f"] = true, 
	["keys.g"] = true, 
	["keys.h"] = true, 
	["keys.i"] = true, 
	["keys.j"] = true, 
	["keys.k"] = true, 
	["keys.l"] = true, 
	["keys.m"] = true, 
	["keys.n"] = true, 
	["keys.o"] = true, 
	["keys.p"] = true, 
	["keys.q"] = true, 
	["keys.r"] = true, 
	["keys.s"] = true, 
	["keys.t"] = true, 
	["keys.u"] = true, 
	["keys.v"] = true, 
	["keys.w"] = true, 
	["keys.x"] = true, 
	["keys.y"] = true, 
	["keys.z"] = true, 
	["keys.one"] = true, 
	["keys.two"] = true, 
	["keys.three"] = true, 
	["keys.four"] = true, 
	["keys.five"] = true, 
	["keys.six"] = true, 
	["keys.seven"] = true, 
	["keys.eight"] = true, 
	["keys.nine"] = true, 
	["keys.zero"] = true, 
	["keys.minus"] = true, 
	["keys.equals"] = true, 
	["keys.backspace"] = true, 
	["keys.tab"] = true, 
	["keys.leftBracket"] = true, 
	["keys.rightBracket"] = true, 
	["keys.enter"] = true, 
	["keys.leftCtrl"] = true, 
	["keys.semiColon"] = true, 
	["keys.apostrophe"] = true, 
	["keys.grave"] = true, 
	["keys.leftShift"] = true, 
	["keys.backslash"] = true, 
	["keys.comma"] = true, 
	["keys.period"] = true, 
	["keys.slash"] = true, 
	["keys.rightShift"] = true, 
	["keys.multiply"] = true, 
	["keys.leftAlt"] = true, 
	["keys.space"] = true, 
	["keys.capsLock"] = true, 
	["keys.f1"] = true, 
	["keys.f2"] = true, 
	["keys.f3"] = true, 
	["keys.f4"] = true, 
	["keys.f5"] = true, 
	["keys.f6"] = true, 
	["keys.f7"] = true, 
	["keys.f8"] = true, 
	["keys.f9"] = true, 
	["keys.f10"] = true, 
	["keys.numLock"] = true, 
	["keys.scollLock"] = true, 
	["keys.numPad7"] = true, 
	["keys.numPad8"] = true, 
	["keys.numPad9"] = true, 
	["keys.numPadSubtract"] = true, 
	["keys.numPad4"] = true, 
	["keys.numPad5"] = true, 
	["keys.numPad6"] = true, 
	["keys.numPadAdd"] = true, 
	["keys.numPad1"] = true, 
	["keys.numPad2"] = true, 
	["keys.numPad3"] = true, 
	["keys.numPad0"] = true, 
	["keys.numPadDecimal"] = true, 
	["keys.f11"] = true, 
	["keys.f12"] = true, 
	["keys.f13"] = true, 
	["keys.f14"] = true, 
	["keys.f15"] = true, 
	["keys.kana"] = true, 
	["keys.convert"] = true, 
	["keys.noconvert"] = true, 
	["keys.yen"] = true, 
	["keys.numPadEquals"] = true, 
	["keys.cimcumflex"] = true, 
	["keys.at"] = true, 
	["keys.colon"] = true, 
	["keys.underscore"] = true, 
	["keys.kanji"] = true, 
	["keys.stop"] = true, 
	["keys.ax"] = true, 
	["keys.numPadEnter"] = true, 
	["keys.rightCtrl"] = true, 
	["keys.numPadComma"] = true, 
	["keys.numPadDivide"] = true, 
	["keys.rightAlt"] = true, 
	["keys.pause"] = true, 
	["keys.home"] = true, 
	["keys.up"] = true, 
	["keys.pageUp"] = true, 
	["keys.left"] = true, 
	["keys.right"] = true, 
	["keys.down"] = true, 
	["keys.pageDown"] = true, 
	["keys.insert"] = true, 
	["keys.delete"] = true, 
}

local function tryWrite(line, regex, color)
	local match = string.match(line, regex)
	if match then
		if type(color) == "number" then
			term.setTextColor(color)
		else
			term.setTextColor(color(match))
		end
		term.write(match)
		term.setTextColor(textColor)
		return string.sub(line, string.len(match) + 1)
	end
	return nil
end

local function writeHighlighted(line)
	while string.len(line) > 0 do	
		line = 
			tryWrite(line, "^%-%-%[%[.-%]%]", commentColor) or
			tryWrite(line, "^%-%-.*", commentColor) or
			tryWrite(line, "^\".-[^\\]\"", stringColor) or
			tryWrite(line, "^\'.-[^\\]\'", stringColor) or
			tryWrite(line, "^%[%[.-%]%]", stringColor) or
			tryWrite(line, "^%-?%d+", numberColor) or
			tryWrite(line, "^%-?%d+%.%d+", numberColor) or
			tryWrite(line, "^%-?%d+[eE][%+%-]%d+", numberColor) or
			tryWrite(line, "^%-?%d+[eE]%d+", numberColor) or
			tryWrite(line, "^%-?%d+%.%d+[eE][%+%-]%d+", numberColor) or
			tryWrite(line, "^%-?%d+%.%d+[eE]%d+", numberColor) or
			tryWrite(line, "^[%w_]+%.[%w_]+", function(match)
				if functions[match] then
					return functionColor
				elseif vars[match] then
					return varColor
				end
				return textColor
			end) or
			tryWrite(line, "^[%w_]+", function(match)
				if keywords[match] then
					return keywordColor
				elseif functions[match] then
					return functionColor
				elseif vars[match] then
					return varColor
				end
				return textColor
			end) or
			tryWrite(line, "^[^%w_]", textColor)
	end
end

local function redrawHead()
	menuHeight = 1
	term.setBackgroundColor(menuBgColor)
	term.setCursorPos(1, menuHeight)
	term.clearLine()
	
	for k, v in pairs(names) do
	
		term.setTextColor(menuTextcolor)
		
		if readOnly[k] then
			term.setTextColor(readOnlyColor)
		end
		
		if term.getCursorPos() > w - v:len() - 1 then
			menuHeight = menuHeight + 1
			term.setCursorPos(1, menuHeight)
			term.setBackgroundColor(menuBgColor)
			term.clearLine()
		end
		
		positions[k] = {term.getCursorPos()}
		
		if k == current then
			term.setBackgroundColor(selectedColor)
		else
			term.setBackgroundColor(unselectedColor)
		end
		
		term.write(v)
		term.setTextColor(closeColor)
		term.write("x ")
	end
	
	term.setBackgroundColor(menuBgColor)
	if term.getCursorPos() > w then
		menuHeight = menuHeight + 1
		term.setCursorPos(1, menuHeight)
		term.setBackgroundColor(menuBgColor)
		term.clearLine()
	end
	
	openPosition = {term.getCursorPos()}
	term.setTextColor(openColor)
	term.write("+")
end

local function insureLength(s, len)
	while s:len() < len do
		s = s .. " "
	end
	return s
end

local function redrawLine(i)
	if lines[current][i] ~= nil then
		writeHighlighted(lines[current][i])
	end
		
		term.setCursorPos(1, i + menuHeight - scrollY[current])
		term.setBackgroundColor(menuBgColor)
		term.setTextColor(lineNumColor)
		term.write(insureLength(tostring(i), lineNumLen))
end

local function redrawText(cursorBlink)
	lineNumLen = math.max(string.len(tostring(#lines[current])), 2)
	for i = 1, h - menuHeight do
		term.setCursorPos(lineNumLen + 1 - scrollX[current], i + menuHeight)
		term.setBackgroundColor(bgColor)
		term.clearLine()
		redrawLine(i + scrollY[current])
	end
	
	if cursorBlink == nil then
		cursorBlink = true
	end
	
	if x[current] - scrollX[current] < 1 or y[current] - scrollY[current] < 1 then
		term.setCursorBlink(false)
	else
		if type(cursorBlink) ~= "boolean" then
			error(type(cursorBlink))
		end
		term.setCursorBlink(cursorBlink)
	end
	
	term.setTextColor(textColor)
	term.setCursorPos(x[current] - scrollX[current] + lineNumLen, y[current] - scrollY[current] + menuHeight)
end

local function drawCursor()
	local screenX = x[current] - scrollX[current]
	local screenY = y[current] - scrollY[current]
	
	local redraw = false
	if screenX < 1 then
		scrollX[current] = x[current] - 1
		screenX = 1
		redraw = true
	elseif screenX > w - lineNumLen then
		scrollX[current] = x[current] - w + lineNumLen
		screenX = w - lineNumLen
		redraw = true
	end
	
	if screenY < 1 then
		scrollY[current] = y[current] - 1
		screenY = 1
		redraw = true
	elseif screenY > h - menuHeight then
		scrollY[current] = y[current] - h + menuHeight
		screenY = h - menuHeight
		redraw = true
	end
	
	if redraw then
		redrawText()
	end
	
	if cursorBlink == nil then
		cursorBlink = true
	end
	
	if screenX < 1 or screenY < 1 then
		term.setCursorBlink(false)
	else
		term.setCursorBlink(cursorBlink)
	end
	
	term.setTextColor(textColor)
	term.setCursorPos(screenX + lineNumLen, screenY + menuHeight)
end

local function redrawMenu()
	if menu then
		term.setCursorBlink(false)
		term.setCursorPos(1, h)
		term.clearLine()
		
		term.setTextColor(textColor)
		for k, v in ipairs(menuItems) do
			if k == menuItem then
				term.setTextColor(selectedColor)
			else
				term.setTextColor(menuTextcolor)
			end
			term.write("[")
			term.write(v)
			term.write("]")
		end
	end
end

local menuFuncs = {
	Save = function()
		for k, _ in pairs(opened) do
			save(k)
		end
	end, 
	
	Exit = function()
		running = false
	end, 
	Run = function()
		for k, _ in pairs(opened) do
			save(k)
		end
		term.setBackgroundColor(colors.black)
		term.setTextColor(colors.white)
		term.setCursorPos(1, 1)
		term.clear()
		term.write("Arguments: ")
		shell.run(current .. " " .. read())
		term.setBackgroundColor(colors.black)
		term.setTextColor(colors.white)
		print("press enter to return to edit++...")
		while true do
			local event, a = os.pullEvent()
			if event == "key" and a == keys.enter then break end
		end
		redrawHead()
		redrawText()
		redrawMenu()
	end
}

local function doMenuItem(i)
	menuFuncs[menuItems[i]]()
	menu = false
	redrawText()
end

local function fullList(dir)
	local contents = fs.list(dir)
	contents.fullName = dir
	contents.name = fs.getName(dir)
	contents.open = true
	for k, v in ipairs(contents) do
		if fs.isDir(dir .. v) then
			contents[k] = fullList(dir .. v .. "/")
		else
			contents[k] = dir .. contents[k]
		end
	end
	return contents
end

local function renderFolder(contents)
	term.setTextColor(colors.green)
	local _, indentation = string.gsub(contents.fullName, "/", "/")
	if contents.open then
		term.write(string.rep("  ", indentation - 1) .. "v " .. contents.name)
		local _, _y = term.getCursorPos()
		for k, v in ipairs(contents) do
			term.setCursorPos(1, _y + 1)
			if type(v) == "string" then
				term.setTextColor(colors.white)
				term.write(string.rep("  ", indentation) .. fs.getName(v))
			else
				renderFolder(v)
			end
			_, _y = term.getCursorPos()
		end
	else
		term.write(string.rep("  ", indentation - 1) .. "> " .. contents.name)
	end
end

local function fileChooser()
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	term.clear()
	term.setCursorPos(1, 1)
	term.setCursorBlink(false)
	local contents = fullList("/")
	renderFolder(contents)
	sleep(10)
	return current
end
	

term.setBackgroundColor(bgColor)
term.clear()
open(original)
redrawHead()
redrawText()
redrawMenu()
drawCursor()

while running do
	local event, a, b, c = os.pullEvent()
	if event == "key" then
		if a == keys.up then
			if not menu then
				if y[current] > 1 then
					y[current] = y[current] - 1
					x[current] = math.min(x[current], string.len(lines[current][y[current]]) + 1)
					drawCursor()
				end
			end
		elseif a == keys.down then
			if not menu then
				if y[current] < #lines[current] then
					y[current] = y[current] + 1
					x[current] = math.min( x[current], string.len(lines[current][y[current]]) + 1)
					drawCursor()
				end
			end
		elseif a == keys.tab then
			if not menu and not readOnly[current] then
				lines[current][y[current]] = "  " .. lines[current][y[current]]
				x[current] = x[current] + 2
				drawCursor()
				redrawText()
			end
		elseif a == keys.pageUp then
			if not menu then
				if y[current] - (h - menuHeight) >= 1 then
					y[current] = y[current] - (h - menuHeight)
				else
					y[current] = 1
				end
				x[current] = math.min(x[current], string.len(lines[current][y[current]]) + 1)
				drawCursor()
			end
		elseif a == keys.pageDown then
			if not menu then
				if y[current] + (h - menuHeight) <= #lines[current] then
					y[current] = y[current] + (h - menuHeight)
				else
					y[current] = #lines[current]
				end
				x[current] = math.min(x[current], string.len(lines[current][y[current]]) + 1)
				drawCursor()
			end
		elseif a == keys.home then
			if not menu then
				x[current] = 1
				drawCursor()
			end
		elseif a == keys["end"] then
			if not menu then
				x[current] = string.len(lines[current][y[current]]) + 1
				drawCursor()
			end
		elseif a == keys.left then
			if not menu then
				if x[current] > 1 then
					x[current] = x[current] - 1
				elseif x[current] == 1 and y[current] > 1 then
					x[current] = string.len(lines[current][y[current] - 1]) + 1
					y[current] = y[current] - 1
				end
				drawCursor()
			else
				menuItem = menuItem - 1
				if menuItem < 1 then
					menuItem = #menuItems
				end
				redrawMenu()
			end
		elseif a == keys.right then
			if not menu then
				if x[current] < string.len(lines[current][y[current]]) + 1 then
					x[current] = x[current] + 1
				elseif x[current] == string.len(lines[current][y[current]]) + 1 and y[current] < #lines[current] then
					x[current] = 1
					y[current] = y[current] + 1
				end
				drawCursor()
			else
				menuItem = menuItem + 1
				if menuItem > #menuItems then
					menuItem = 1
				end
				redrawMenu()
			end
		elseif a == keys.delete then
			if not menu and not readOnly[current] then
				if  x[current] < string.len(lines[current][y[current]]) + 1 then
					local line = lines[current][y[current]]
					lines[current][y[current]] = string.sub(line, 1, x[current] - 1) .. string.sub(line, x[current] + 1)
					redrawText()
				elseif y[current] < #lines[current] then
					lines[current][y[current]] = lines[current][y[current]] .. lines[current][y[current] + 1]
					table.remove(lines[current], y[current] + 1)
					redrawText()
				end
			end
		elseif a == keys.backspace then
			if not menu and not readOnly[current] then
				if x[current] > 1 then
					local line = lines[current][y[current]]
					lines[current][y[current]] = string.sub(line, 1, x[current] - 2) .. string.sub(line, x[current])
					redrawText()
			
					x[current] = x[current] - 1
					drawCursor()
				elseif y[current] > 1 then
					local prevLen = string.len(lines[current][y[current] - 1])
					lines[current][y[current] - 1] = lines[current][y[current] - 1] .. lines[current][y[current]]
					table.remove(lines[current], y[current])
					redrawText()
				
					x[current] = prevLen + 1
					y[current] = y[current] - 1
					drawCursor()
				end
			end
		elseif a == keys.leftCtrl or a == 157 then
			if menu then
				menu = false
				redrawText()
			else
				menu = true
				redrawMenu()
			end
		elseif a == keys.enter then
			if not menu and not readOnly[current] then
				line = lines[current][y[current]]
				local _, spaces = string.find(line, "^[ ]+")
				if not spaces then
					spaces = 0
				end
				
				lines[current][y[current]] = string.sub(line, 1, x[current] - 1)
				
			
				table.insert(lines[current], y[current] + 1, string.rep(" ", spaces) .. string.sub(line, x[current]))
				
				x[current] = spaces + 1
				y[current] = y[current] + 1
				redrawText()
				drawCursor()
			elseif menu then
				doMenuItem(menuItem)
			end
		end
	elseif event == "char" then
		if not (menu or readOnly[current]) then
			local line = lines[current][y[current]]
			lines[current][y[current]] = string.sub(line, 1, x[current] - 1) .. a .. string.sub(line, x[current])
			redrawText()
		
			x[current] = x[current] + 1
			drawCursor()
			term.setTextColor(colors.black)
		elseif menu then
			for i, _menuItem in ipairs(menuItems) do
				if string.lower(string.sub(_menuItem, 1, 1)) == string.lower(a) then
					doMenuItem(i)
					break
				end
			end
		end
	elseif event == "paste" then
		if not menu and not readOnly[current] then
			local line = lines[current][y[current]]
			lines[current][y[current]] = string.sub(line, 1, x[current] - 1) .. a .. string.sub(line, x[current])
			redrawText()

			x[current] = x[current] + string.len(a)
			drawCursor()
		end
	elseif event == "mouse_click" then
		if a == 1 then
			local cx,cy = b, c
			if not menu and cy > menuHeight and cx > lineNumLen then
				y[current] = math.min(math.max(scrollY[current] + cy - menuHeight, 1), #lines[current])
				x[current] = math.min(math.max(scrollX[current] + cx - lineNumLen, 1), string.len(lines[current][y[current]]) + 1)
				drawCursor()
			elseif cy <= menuHeight then
				for k, v in pairs(positions) do
					if cx == v[1] + string.len(names[k]) and cy == v[2] then
						save(k)
						close(k)
						local i = 0
						for k, v in pairs(opened) do
							i = i + 1
						end
						if i == 0 then
							running = false
							break
						end
						redrawHead()
						redrawText()
						redrawMenu()
						break
					elseif cx >= v[1] and cx < v[1] + string.len(names[k]) + 2 and cy == v[2] then
						current = k
						redrawHead()
						redrawText()
						redrawMenu()
						break
					end
				end
				if cx == openPosition[1] and cy == openPosition[2] then
					-- open(fileChooser())
					term.setBackgroundColor(colors.black)
					term.setTextColor(colors.white)
					term.clear()
					term.setCursorPos(1, 1)
					term.write("Select a file: ")
					open(read())
					redrawHead()
					redrawText()
					redrawMenu()
				end
			end
		end
	elseif event == "mouse_scroll" then
		if not menu then
			if a == -1 then
				if scrollY[current] > 0 then
					scrollY[current] = scrollY[current] - 1
					redrawText()
				end
			elseif a == 1 then
				local maxScroll = #lines[current] - (h - 1)
				if scrollY[current] < maxScroll then
					scrollY[current] = scrollY[current] + 1
					redrawText()
				end
				
			end
		end
	elseif event == "term_resize" then
		w, h = term.getSize()
		redrawHead()
		redrawText()
		redrawMenu()
		drawCursor()
	end
end

term.setBackgroundColor(colors.black)
term.clear()
term.setCursorPos(1, 1)
