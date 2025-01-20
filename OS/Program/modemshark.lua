-- ModemShark: Modem packet sniffer for ComputerCraft
-- By JackMacWindows
-- Licensed under GPLv2+

--@Devos_not_resizable

local stackWindow, viewerWindow, lines, scrollPos
local w, h = term.getSize()
local selectedLine
local stack = {}
local file

local function drawTraceback()
    if viewerWindow then
        viewerWindow.clear()
        viewerWindow.setVisible(false)
        viewerWindow = nil
    end
    stackWindow = window.create(term.current(), 1, 1, w, math.max(#stack + 1, h))
    stackWindow.clear()
    stackWindow.setCursorPos(1, 1)
    stackWindow.setBackgroundColor(colors.white)
    stackWindow.setTextColor(colors.blue)
    stackWindow.clearLine()
    stackWindow.write(" ModemShark")
    stackWindow.setCursorPos(1, 2)
    stackWindow.setBackgroundColor(colors.black)
    stackWindow.setTextColor(colors.white)
    local numWidth, sourceWidth, nameWidth = 7, 6, 6
    stackWindow.write("Side")
    stackWindow.setCursorPos(numWidth, 2)
    stackWindow.write("Ch.")
    stackWindow.setCursorPos(numWidth + sourceWidth, 2)
    stackWindow.write("Reply")
    stackWindow.setCursorPos(numWidth + sourceWidth + nameWidth, 2)
    stackWindow.write("Time")
    for i,v in ipairs(stack) do
        stackWindow.setCursorPos(1, i + 2)
        stackWindow.setBackgroundColor(selectedLine == i+1 and colors.blue or (i % 2 == 1 and colors.gray or colors.black))
        stackWindow.setTextColor(colors.white)
        stackWindow.clearLine()
        stackWindow.write(v.side)
        stackWindow.setCursorPos(numWidth, i + 2)
        stackWindow.write(v.channel)
        stackWindow.setCursorPos(numWidth + sourceWidth, i + 2)
        stackWindow.write(v.replyChannel)
        stackWindow.setCursorPos(numWidth + sourceWidth + nameWidth, i + 2)
        stackWindow.write(textutils.formatTime(v.time))
    end
    if #stack < h - 1 then for i = #stack + 1, h - 1 do 
        stackWindow.setCursorPos(1, i + 2)
        stackWindow.setBackgroundColor(i % 2 == 1 and colors.gray or colors.black)
        stackWindow.clearLine()
    end end
end

local function renderFile()
    if lines == nil then return end
    viewerWindow.setCursorPos(1, 2)
    for i = scrollPos, scrollPos + h - 2 do 
        viewerWindow.setBackgroundColor(colors.black)
        viewerWindow.setTextColor(colors.white)
        viewerWindow.clearLine()
        if lines[i] ~= nil then viewerWindow.write(lines[i]) end
        if i ~= scrollPos + h then viewerWindow.setCursorPos(1, select(2, viewerWindow.getCursorPos()) + 1) end
    end
    local r = (#lines - h + 3) / (h - 1)
    for i = 2, h do
        viewerWindow.setCursorPos(w, i)
        viewerWindow.blit(" ", "0", (scrollPos >= r * (i - 2) and scrollPos < r * (i - 1)) and "8" or "7")
    end
end

local function showFile(info)
    if stackWindow then
        stackWindow.clear()
        stackWindow.setVisible(false)
        stackWindow = nil
    end
    viewerWindow = window.create(term.current(), 1, 1, w, h)
    viewerWindow.clear()
    viewerWindow.setCursorPos(1, 1)
    viewerWindow.setTextColor(colors.blue)
    viewerWindow.setBackgroundColor(colors.white)
    viewerWindow.clearLine()
    viewerWindow.write(" " .. string.char(17) .. " Message Details")
    viewerWindow.setCursorPos(1, 2)
    lines = {
        "Side: " .. info.side,
        "Channel: " .. info.channel,
        "Reply Channel: " .. info.replyChannel,
        "Distance: " .. (info.distance or "?"),
        "Time: " .. textutils.formatTime(info.time),
        ""
    }
    if type(info.message) == "boolean" then lines[7] = info.message and "true" or "false"
    elseif type(info.message) == "number" then lines[7] = tostring(info.message)
    elseif type(info.message) == "string" then
        local str = ""
        for word in info.message:gmatch "[^ ]+" do
            while #str + #word + 1 > w do
                if str == "" then
                    table.insert(lines, word:sub(1, w))
                    word = word:sub(w+1)
                else
                    table.insert(lines, str)
                    str = ""
                end
            end
            if word ~= "" then str = str .. (str == "" and "" or " ") .. word end
        end
        if str ~= "" then table.insert(lines, str) end
    elseif info.message == nil then lines[7] = "nil"
    elseif type(info.message) == "table" then
        local str = textutils.serialize(info.message)
        for line in str:gmatch "[^\n]+" do table.insert(lines, line) end
    else lines[7] = tostring(info.message) end
    scrollPos = 1
    renderFile()
end

if ... then
    local modem = peripheral.find("modem")
    if modem ~= nil then for _,i in ipairs({...}) do
        if tonumber(i) ~= nil then modem.open(tonumber(i))
        elseif file == nil then file = fs.open(i, "a") end
    end end
end

local screen = false

drawTraceback()
scrollPos = 1
while true do
    local evtab = {os.pullEvent()}
    local ev, p1, p2, p3 = table.unpack(evtab)
    if ev == "key" then 
        if p1 == keys.enter then
            if selectedLine ~= nil then
                showFile(stack[selectedLine-1])
                screen = true
            end
        elseif p1 == keys.up then
            if screen then
                if scrollPos > 1 then 
                    scrollPos = scrollPos - 1 
                    renderFile()
                end
            else
                if selectedLine == nil then selectedLine = 1 end
                if selectedLine > 1 then
                    selectedLine = selectedLine - 1
                    if scrollPos > selectedLine then scrollPos = selectedLine end
                    drawTraceback()
                    stackWindow.reposition(1, 2 - scrollPos)
                end
            end
        elseif p1 == keys.down then
            if screen then
                if scrollPos < #lines - h + 2 then 
                    scrollPos = scrollPos + 1
                    renderFile()
                end
            else
                if selectedLine == nil then selectedLine = 0 end
                if stack[selectedLine] then
                    selectedLine = selectedLine + 1
                    if scrollPos + h - 2 < selectedLine then scrollPos = scrollPos + 1 end
                    drawTraceback()
                    stackWindow.reposition(1, 2 - scrollPos)
                end
            end
        elseif p1 == keys.left and screen then
            selectedLine = nil
            screen = false
            scrollPos = 1
            drawTraceback()
        elseif p1 == keys.right and not screen and selectedLine ~= nil and stack[selectedLine-1] ~= nil then
            showFile(stack[selectedLine-1])
            screen = true
        end
    elseif ev == "char" and p1 == "q" then
        term.setCursorPos(1, 1)
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.clear()
        break
    elseif ev == "mouse_click" and p1 == 1 then 
        if screen then
            if p2 >= 1 and p2 <= 3 and p3 == 1 then
                selectedLine = nil
                screen = false
                scrollPos = 1
                drawTraceback()
            end
        else
            if selectedLine == p3 - 2 + scrollPos and stack[selectedLine-1] ~= nil then
                showFile(stack[selectedLine-1])
                screen = true
            elseif stack[p3 - 3 + scrollPos] then
                selectedLine = p3 - 2 + scrollPos
                drawTraceback()
                stackWindow.reposition(1, 2 - scrollPos)
            end
        end
    elseif ev == "mouse_scroll" then
        if screen then
            if p1 == 1 and scrollPos < #lines - h + 2 then 
                scrollPos = scrollPos + 1
                renderFile()
            elseif p1 == -1 and scrollPos > 1 then 
                scrollPos = scrollPos - 1 
                renderFile()
            end
        else
            local _, vwh = stackWindow.getSize()
            if p1 == 1 and scrollPos < vwh - h + 1 then 
                scrollPos = scrollPos + 1
                stackWindow.reposition(1, 2 - scrollPos)
            elseif p1 == -1 and scrollPos > 1 then 
                scrollPos = scrollPos - 1 
                stackWindow.reposition(1, 2 - scrollPos)
            end
        end
    elseif ev == "modem_message" then
        table.insert(stack, 1, {side = evtab[2], channel = evtab[3], replyChannel = evtab[4], message = evtab[5], distance = evtab[6], time = os.time()})
        if file then
            file.writeLine(("[%s] Received message on side '%s' from channel %d, reply to %d (distance %d)"):format(textutils.formatTime(os.time()), evtab[2], evtab[3], evtab[4], evtab[6]))
            if type(evtab[5]) == "boolean" then file.writeLine(evtab[5] and "true" or "false")
            elseif type(evtab[5]) == "number" or type(evtab[5]) == "string" then file.writeLine(evtab[5])
            elseif evtab[5] == nil then file.writeLine("nil")
            elseif type(evtab[5]) == "table" then file.writeLine(textutils.serialize(evtab[5]))
            else file.writeLine(tostring(evtab[5])) end
            file.writeLine("")
            file.flush()
        end
        if not screen then drawTraceback() end
    end
end
if file then file.close() end