local basalt = require('./Devos/sys32/basalt')

local main = basalt.createFrame()
    :setBackground(colors.black)
    :setForeground(colors.white)

local leftSide = main:addFrame()
    :setPosition(1,1)
    :setSize(15,"parent.h")
    :setBackground(colors.gray)
    :setForeground(colors.white)

function add_separator(x,y)
    leftSide:addPane()
        :setSize("parent.w - 2", 1)
        :setPosition(x, y)
        :setBackground(false, "\140", colors.white)
end

leftSide:addLabel()
    :setSize("parent.w",1)
    :setText("Settings")
    :setTextAlign("center")
    
add_separator(2,2)

local view = main:addFrame()
    :setPosition(16,1)
    :setSize("parent.w-15","parent.h")
    :setBackground(colors.black)
    :setForeground(colors.white)

-- separator

local home_frame = view:addFrame()
    :setPosition(1,1)
    :setSize("parent.w","parent.h")
    :setBackground(colors.black)
    :setForeground(colors.white)
    
home_frame:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setPosition(2,2)
    :setText("Home")
    :setFontSize(2)
        
home_frame:addPane()
    :setSize("parent.w-1",1)
    :setPosition(2,6)
    :setBackground(false,'\140',colors.white)
    
local home_content = home_frame:addScrollableFrame()
    :setPosition(2,7)
    :setSize("parent.w-1","parent.h-7")
    :setBackground(colors.black)
    
-- separator

local flexbox = home_content:addFlexbox():setWrap("wrap")
    :setPosition(1,1)
    :setSize("parent.w","parent.h")
    :setBackground(colors.black)

-- separator

local window_frame = view:addFrame()
    :setPosition(1,1)
    :setSize("parent.w","parent.h")
    :setBackground(colors.black)
    :setForeground(colors.white)
    
window_frame:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setPosition(2,2)
    :setText("Window")
    :setFontSize(2)
        
window_frame:addPane()
    :setSize("parent.w-1",1)
    :setPosition(2,6)
    :setBackground(false,'\140',colors.white)
    
local window_content = window_frame:addScrollableFrame()
    :setPosition(2,7)
    :setSize("parent.w-1","parent.h-7")
    :setBackground(colors.black)

-- separator

window_content:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setText('Titlebar button style :')
    :setPosition(1,1)
    :setSize(22,1)

window_switch2 = window_content:addMenubar()
    :setPosition(3,2)
    :setSize("parent.w-4",1)
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setSelectionColor(colors.blue, colors.black)
    :addItem('small',colors.black,colors.white)
    :addItem('large',colors.black,colors.white)
    :setSpace(4)
    :onChange(function(self,event,item)
        local file = fs.open('./Data/titlebarstylebt.conf','w+')
        file.write(item.text)
        file.close()
    end)

window_content:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setText('Use new edit :')
    :setPosition(1,4)
    :setSize(22,1)

window_switch3 = window_content:addMenubar()
    :setPosition(3,5)
    :setSize("parent.w-4",1)
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setSelectionColor(colors.blue, colors.black)
    :addItem('no',colors.black,colors.white)
    :addItem('yes',colors.black,colors.white)
    :setSpace(4)
    :onChange(function(self,event,item)
        local file = fs.open('./Data/usenewedit.conf','w+')
        if item.text == 'yes' then
            file.write('true')
            shell.setAlias("edit", "Devos/edit.lua")
        else
            file.write('false')
            shell.clearAlias("edit")
        end
        file.close()
        if item.text == 'no' then
            self:setSelectionColor(colors.red, colors.black)
        elseif item.text == 'yes' then
            self:setSelectionColor(colors.green, colors.black)
        else
            self:setSelectionColor(colors.blue, colors.black)
        end
    end)

local file = fs.open('./Data/titlebarstylebt.conf','r')
local content = file.readAll()
if content == 'small' then
    window_switch2:selectItem(1)
else
    window_switch2:selectItem(2)
end
file.close()

local file = fs.open('./Data/usenewedit.conf','r')
local content = file.readAll()
if content == 'false' then
    window_switch3:selectItem(1)
    window_switch3:setSelectionColor(colors.red, colors.black)
else
    window_switch3:selectItem(2)
    window_switch3:setSelectionColor(colors.green, colors.black)
end
file.close()

-- separator

local rednet_frame = view:addFrame()
    :setPosition(1,1)
    :setSize("parent.w","parent.h")
    :setBackground(colors.black)
    :setForeground(colors.white)
    
rednet_frame:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setPosition(2,2)
    :setText("Rednet")
    :setFontSize(2)
        
rednet_frame:addPane()
    :setSize("parent.w-1",1)
    :setPosition(2,6)
    :setBackground(false,'\140',colors.white)
    
local rednet_content = rednet_frame:addScrollableFrame()
    :setPosition(2,7)
    :setSize("parent.w-1","parent.h-7")
    :setBackground(colors.black)

-- separator

rednet_content:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setText('Allow FTP :')
    :setPosition(1,1)
    :setSize(22,1)

rednet_switch3 = rednet_content:addMenubar()
    :setPosition(3,2)
    :setSize("parent.w-4",1)
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setSelectionColor(colors.blue, colors.black)
    :addItem('no',colors.black,colors.white)
    :addItem('yes',colors.black,colors.white)
    :addItem('only x times',colors.black,colors.white)
    :setSpace(4)
    :onChange(function(self,event,item)
        local file = fs.open('./Data/allowftp.conf','w+')
        file.write(item.text)
        file.close()
        if item.text == 'no' then
            self:setSelectionColor(colors.red, colors.black)
        elseif item.text == 'yes' then
            self:setSelectionColor(colors.green, colors.black)
        else
            self:setSelectionColor(colors.blue, colors.black)
        end
    end)

rednet_content:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setText('x Times :')
    :setPosition(1,4)
    :setSize(22,1)

rednet_switch3_drop = rednet_content:addList()
    :setPosition(3,5)
    :setSize(15,30)
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :addItem('1',colors.gray,colors.white)
    :addItem('2',colors.gray,colors.white)
    :addItem('3',colors.gray,colors.white)
    :addItem('4',colors.gray,colors.white)
    :addItem('5',colors.gray,colors.white)
    :addItem('6',colors.gray,colors.white)
    :addItem('7',colors.gray,colors.white)
    :addItem('8',colors.gray,colors.white)
    :addItem('9',colors.gray,colors.white)
    :addItem('10',colors.gray,colors.white)
    
    :addItem('11',colors.gray,colors.white)
    :addItem('12',colors.gray,colors.white)
    :addItem('13',colors.gray,colors.white)
    :addItem('14',colors.gray,colors.white)
    :addItem('15',colors.gray,colors.white)
    :addItem('16',colors.gray,colors.white)
    :addItem('17',colors.gray,colors.white)
    :addItem('18',colors.gray,colors.white)
    :addItem('19',colors.gray,colors.white)
    :addItem('20',colors.gray,colors.white)
    
    :addItem('21',colors.gray,colors.white)
    :addItem('22',colors.gray,colors.white)
    :addItem('23',colors.gray,colors.white)
    :addItem('24',colors.gray,colors.white)
    :addItem('25',colors.gray,colors.white)
    :addItem('26',colors.gray,colors.white)
    :addItem('27',colors.gray,colors.white)
    :addItem('28',colors.gray,colors.white)
    :addItem('29',colors.gray,colors.white)
    :addItem('30',colors.gray,colors.white)
    
    :addItem('31',colors.gray,colors.white)
    :addItem('32',colors.gray,colors.white)
    :addItem('33',colors.gray,colors.white)
    :addItem('34',colors.gray,colors.white)
    :addItem('35',colors.gray,colors.white)
    :addItem('36',colors.gray,colors.white)
    :addItem('37',colors.gray,colors.white)
    :addItem('38',colors.gray,colors.white)
    :addItem('39',colors.gray,colors.white)
    :addItem('40',colors.gray,colors.white)
    
    :addItem('41',colors.gray,colors.white)
    :addItem('42',colors.gray,colors.white)
    :addItem('43',colors.gray,colors.white)
    :addItem('44',colors.gray,colors.white)
    :addItem('45',colors.gray,colors.white)
    :addItem('46',colors.gray,colors.white)
    :addItem('47',colors.gray,colors.white)
    :addItem('48',colors.gray,colors.white)
    :addItem('49',colors.gray,colors.white)
    :addItem('50',colors.gray,colors.white)
    :onChange(function(self,event,item)
        local file = fs.open('./Data/ftptime.conf','w+')
        file.write(item.text)
        file.close()
        if tonumber(item.text) >= 1 and tonumber(item.text) <= 10 then
            self:setSelectionColor(colors.green, colors.black)
        elseif tonumber(item.text) >= 11 and tonumber(item.text) <= 20 then
            self:setSelectionColor(colors.cyan, colors.black)
        elseif tonumber(item.text) >= 21 and tonumber(item.text) <= 30 then
            self:setSelectionColor(colors.yellow, colors.black)
        elseif tonumber(item.text) >= 31 and tonumber(item.text) <= 40 then
            self:setSelectionColor(colors.orange, colors.black)
        elseif tonumber(item.text) >= 41 and tonumber(item.text) <= 50 then
            self:setSelectionColor(colors.red, colors.black)
        end
    end)

local file = fs.open('./Data/allowftp.conf','r')
local content = file.readAll()
if content == 'no' then
    rednet_switch3:selectItem(1)
    rednet_switch3:setSelectionColor(colors.red, colors.black)
elseif content == 'yes' then
    rednet_switch3:selectItem(2)
    rednet_switch3:setSelectionColor(colors.green, colors.black)
else
    rednet_switch3:selectItem(3)
    rednet_switch3:setSelectionColor(colors.blue, colors.black)
end
file.close()

local file = fs.open('./Data/ftptime.conf','r')
local content = file.readAll()
rednet_switch3_drop:selectItem(tonumber(content))
if tonumber(content) >= 1 and tonumber(content) <= 10 then
    rednet_switch3_drop:setSelectionColor(colors.green, colors.black)
elseif tonumber(content) >= 11 and tonumber(content) <= 20 then
    rednet_switch3_drop:setSelectionColor(colors.cyan, colors.black)
elseif tonumber(content) >= 21 and tonumber(content) <= 30 then
    rednet_switch3_drop:setSelectionColor(colors.yellow, colors.black)
elseif tonumber(content) >= 31 and tonumber(content) <= 40 then
    rednet_switch3_drop:setSelectionColor(colors.orange, colors.black)
elseif tonumber(content) >= 41 and tonumber(content) <= 50 then
    rednet_switch3_drop:setSelectionColor(colors.red, colors.black)
end
file.close()

-- separator

local notif_frame = view:addFrame()
    :setPosition(1,1)
    :setSize("parent.w","parent.h")
    :setBackground(colors.black)
    :setForeground(colors.white)
    
notif_frame:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setPosition(2,2)
    :setText("Notification")
    :setFontSize(2)

notif_frame:addPane()
    :setSize("parent.w-1",1)
    :setPosition(2,6)
    :setBackground(false,'\140',colors.white)
    
local notif_content = notif_frame:addScrollableFrame()
    :setPosition(2,7)
    :setSize("parent.w-1","parent.h-7")
    :setBackground(colors.black)

-- separator

notif_content:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setText('Play sound :')
    :setPosition(1,1)
    :setSize(22,1)

notif_switch5 = notif_content:addMenubar()
    :setPosition(3,2)
    :setSize("parent.w-4",1)
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setSelectionColor(colors.blue, colors.black)
    :addItem('no',colors.black,colors.white)
    :addItem('yes',colors.black,colors.white)
    :setSpace(4)
    :onChange(function(self,event,item)
        local file = fs.open('./Data/playsound.conf','w+')
        file.write(item.text)
        file.close()
        if item.text == 'no' then
            self:setSelectionColor(colors.red, colors.black)
        elseif item.text == 'yes' then
            self:setSelectionColor(colors.green, colors.black)
        else
            self:setSelectionColor(colors.blue, colors.black)
        end
    end)

notif_content:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setText('Startup notif :')
    :setPosition(1,4)
    :setSize(22,1)

notif_switch6 = notif_content:addMenubar()
    :setPosition(3,5)
    :setSize("parent.w-4",1)
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setSelectionColor(colors.blue, colors.black)
    :addItem('no',colors.black,colors.white)
    :addItem('yes',colors.black,colors.white)
    :setSpace(4)
    :onChange(function(self,event,item)
        local file = fs.open('./Data/startupnotif.conf','w+')
        file.write(item.text)
        file.close()
        if item.text == 'no' then
            self:setSelectionColor(colors.red, colors.black)
        elseif item.text == 'yes' then
            self:setSelectionColor(colors.green, colors.black)
        else
            self:setSelectionColor(colors.blue, colors.black)
        end
    end)

notif_content:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setText('Telegram notif :')
    :setPosition(1,7)
    :setSize(22,1)

notif_switch7 = notif_content:addMenubar()
    :setPosition(3,8)
    :setSize("parent.w-4",1)
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setSelectionColor(colors.red, colors.black)
    :addItem('no',colors.black,colors.white)
    :addItem('yes',colors.black,colors.white)
    :setSpace(4)
    :onChange(function(self,event,item)
        local file = fs.open('./Data/telegramnotif.conf','w+')
        file.write(item.text)
        file.close()
        if item.text == 'no' then
            self:setSelectionColor(colors.red, colors.black)
        elseif item.text == 'yes' then
            self:setSelectionColor(colors.green, colors.black)
        else
            self:setSelectionColor(colors.blue, colors.black)
        end
    end)

notif_content:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setText('Telegram bot id :')
    :setPosition(1,10)
    :setSize(22,1)

notif_bot = notif_content:addInput()
    :setPosition(3,11)
    :setSize("parent.w-4",1)
    :setBackground(colors.black)
    :setForeground(colors.white)

notif_content:addPane():setSize("parent.w-4", 1):setPosition(3, 12):setBackground(false, "\131", colors.gray)

notif_content:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setText('Telegram chat id :')
    :setPosition(1,13)
    :setSize(22,1)

notif_channel = notif_content:addInput()
    :setPosition(3,14)
    :setSize("parent.w-4",1)
    :setBackground(colors.black)
    :setForeground(colors.white)

notif_content:addPane():setSize("parent.w-4", 1):setPosition(3, 15):setBackground(false, "\131", colors.gray)

notif_save = notif_content:addButton()
    :setPosition(3,16)
    :setSize("parent.w-4",1)
    :setText('Save')
    :setBackground(colors.blue)
    :setForeground(colors.white)
    :onClick(function(self,event)
        local file = fs.open('./Data/telegrambotid.conf','w+')
        file.write(notif_bot:getValue())
        file.close()
        local file = fs.open('./Data/telegrambotid.conf','r')
        local content = file.readAll()
        notif_bot:setDefaultText(content)
        file.close()
        local file = fs.open('./Data/telegramchatid.conf','w+')
        file.write(notif_channel:getValue())
        file.close()
        local file = fs.open('./Data/telegramchatid.conf','r')
        local content = file.readAll()
        notif_channel:setDefaultText(content)
        file.close()
    end)

local file = fs.open('./Data/playsound.conf','r')
local content = file.readAll()
if content == 'no' then
    notif_switch5:selectItem(1)
    notif_switch5:setSelectionColor(colors.red, colors.black)
else
    notif_switch5:selectItem(2)
    notif_switch5:setSelectionColor(colors.green, colors.black)
end
file.close()

local file = fs.open('./Data/startupnotif.conf','r')
local content = file.readAll()
if content == 'no' then
    notif_switch6:selectItem(1)
    notif_switch6:setSelectionColor(colors.red, colors.black)
else
    notif_switch6:selectItem(2)
    notif_switch6:setSelectionColor(colors.green, colors.black)
end
file.close()

local file = fs.open('./Data/telegramnotif.conf','r')
local content = file.readAll()
if content == 'no' then
    notif_switch7:selectItem(1)
    notif_switch7:setSelectionColor(colors.red, colors.black)
else
    notif_switch7:selectItem(2)
    notif_switch7:setSelectionColor(colors.green, colors.black)
end
file.close()

local file = fs.open('./Data/telegrambotid.conf','r')
local content = file.readAll()
notif_bot:setDefaultText(content)
file.close()

local file = fs.open('./Data/telegramchatid.conf','r')
local content = file.readAll()
notif_channel:setDefaultText(content)
file.close()

-- separator

local info_frame = view:addFrame()
    :setPosition(1,1)
    :setSize("parent.w","parent.h")
    :setBackground(colors.black)
    :setForeground(colors.white)
    
info_frame:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setPosition(2,2)
    :setText("Info")
    :setFontSize(2)

info_frame:addPane()
    :setSize("parent.w-1",1)
    :setPosition(2,6)
    :setBackground(false,'\140',colors.white)
    
local info_content = info_frame:addScrollableFrame()
    :setPosition(2,7)
    :setSize("parent.w-1","parent.h-7")
    :setBackground(colors.black)

-- separator

info_content:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setPosition(1,2)
    :setText("\16 Lua Version  : " .. _VERSION)
    
info_content:addLabel()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setPosition(1,4)
    :setText("\16 Host Version : " .. _HOST)
    
--info_content:addLabel():setBackground(colors.black):setForeground(colors.white):setPosition(1,6):setText("\16 (BETA VERSION)")
info_content:addLabel():setBackground(colors.black):setForeground(colors.white):setPosition(1,6):setText("\16 (ALPHA VERSION)")
    
local file = fs.open('./Data/LICENSES.txt','r')
local data = file.readAll()
file.close()
    
-- separator

local page = leftSide:addList()
    :setPosition(2,3)
    :setSize("parent.w-2","parent.h-3")
    :addItem("Home")
    :addItem("Window")
    :addItem("Rednet")
    :addItem("Notif")
    :addItem("Info")
    :onChange(function(self,event,item)
        local data = item.text
        if data == 'Home' then
            home_frame:show()
            window_frame:hide()
            rednet_frame:hide()
            notif_frame:hide()
            info_frame:hide()
        elseif data == 'Window' then
            home_frame:hide()
            window_frame:show()
            rednet_frame:hide()
            notif_frame:hide()
            info_frame:hide()
        elseif data == 'Rednet' then
            home_frame:hide()
            window_frame:hide()
            rednet_frame:show()
            notif_frame:hide()
            info_frame:hide()
        elseif data == 'Notif' then
            home_frame:hide()
            window_frame:hide()
            rednet_frame:hide()
            notif_frame:show()
            info_frame:hide()
        elseif data == 'Info' then
            home_frame:hide()
            window_frame:hide()
            rednet_frame:hide()
            notif_frame:hide()
            info_frame:show()
        end
    end)

local file = fs.open('./Data/settingdefault.conf','r')
local startstate = file.readAll()
file.close()

if startstate == nil or startstate == 'nil' or startstate == '' then
    home_frame:show()
    window_frame:hide()
    rednet_frame:hide()
    notif_frame:hide()
    info_frame:hide()
    page:selectItem(1)
elseif startstate == 'window' then
    home_frame:hide()
    window_frame:show()
    rednet_frame:hide()
    notif_frame:hide()
    info_frame:hide()
    page:selectItem(2)
elseif startstate == 'rednet' then
    home_frame:hide()
    window_frame:hide()
    rednet_frame:show()
    notif_frame:hide()
    info_frame:hide()
    page:selectItem(3)
elseif startstate == 'notif' then
    home_frame:hide()
    window_frame:hide()
    rednet_frame:hide()
    notif_frame:show()
    info_frame:hide()
    page:selectItem(4)
elseif startstate == 'info' then
    home_frame:hide()
    window_frame:hide()
    rednet_frame:hide()
    notif_frame:hide()
    info_frame:show()
    page:selectItem(5)
end

local file = fs.open('./Data/settingdefault.conf','w+')
file.write('nil')
file.close()

-- separator

basalt.autoUpdate()
