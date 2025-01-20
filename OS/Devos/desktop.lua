-- initialize apis
local basalt = require('./Devos/sys32/basalt')
os.loadAPI('./Devos/sys32/base64')
os.loadAPI('./Devos/sys32/Ldev')

local modem_present = false
local speaker_present = false

local data = peripheral.getNames()
for i in ipairs(data) do
    if peripheral.getType(data[i]) == "modem" then
        rednet.open(data[i])
        modem_present = true
        break
    end
end

local speakerSide = nil

for i in ipairs(data) do
    if peripheral.getType(data[i]) == "speaker" then
        speakerSide = data[i]
        speaker_present = true
        break
    end
end

local hidden = true
local btstyle = 'windows'
local hiden = true
local bookshelf_hidden = false
local notif_expand = false
local playsoundnotif = nil
local file = fs.open('./Data/startupnotif.conf','r')
startnotif = tostring(file.readAll())
file.close()
local file = fs.open('./Data/usenewedit.conf','r')
new = tostring(file.readAll())
file.close()
local file = fs.open('./Data/telegramnotif.conf','r')
telegramnotif = tostring(file.readAll())
file.close()
local file = fs.open('./Data/telegrambotid.conf','r')
telegrambotid = tostring(file.readAll())
file.close()
local file = fs.open('./Data/telegramchatid.conf','r')
telegramchatid = tostring(file.readAll())
file.close()
local id = nil
local msg = nil

if new == "true" then
    shell.setAlias("edit", "./Devos/edit.lua")
end

local function refresh_settings()
    while true do
        local file = fs.open('./Data/playsound.conf','r')
        playsoundnotif = tostring(file.readAll())
        file.close()
        local file = fs.open('./Data/titlebarstylebt.conf','r')
        btstyle = tostring(file.readAll())
        file.close()
        local file = fs.open('./Data/startupnotif.conf','r')
        startnotif = tostring(file.readAll())
        file.close()
        sleep(0.1)
    end
end

-- get data
sleep(0.1)
Wterm,Hterm = term.getSize()

-- setup the screen
local main = basalt.createFrame():setTheme({FrameBG = colors.black, FrameFG = colors.black})

local id = 1
local processes = {}

local notif_frame = main:addFrame()
    :setBackground(colors.gray)
    :setPosition("parent.w+1",3)
    :setSize(29,5)
    :setZIndex(3000)
    :setShadow(colors.black)

local notif_title = notif_frame:addLabel()
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :setText('salut')
    :setPosition(2,2)

local notif_desc = notif_frame:addLabel()
    :setBackground(colors.gray)
    :setForeground(colors.lightGray)
    :setText('')
    :setPosition(2,3)

local notif_expand_bt = notif_frame:addButton()
    :setPosition(1,"parent.h")
    :setSize("parent.w",1)
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :setText('\31')
    :onClick(function(self,event,button,x,y)
        if notif_expand == true then
            notif_frame:animateSize(29,5,0.2)
            notif_expand = false
            self:setText('\31')
        else
            notif_frame:animateSize(29,17,0.2)
            notif_expand = true
            self:setText('\30')
        end
    end)
    
local notif_act_bt_startup = notif_frame:addButton()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setPosition("parent.w-2",2)
    :setSize(1,3)
    :setText('\4')
    
local notif_act_bt_ftp = notif_frame:addButton()
    :setBackground(colors.black)
    :setForeground(colors.white)
    :setPosition("parent.w-2",2)
    :setSize(1,3)
    :setText('\4')

notif_expand = false
notif_expand_bt:setText('\31')

local notif_close = notif_frame:addButton()
    :setPosition("parent.w-1",2)
    :setSize(1,3)
    :setText('x')
    :setBackground(colors.red)
    :setForeground(colors.white)
    :onClick(function()
        notif_frame:animatePosition(Wterm+1,3,0.2)
    end)

function openProgram(path, title, resizable, sizex, sizey, popup)
    local pId = id
    id = id + 1
    f = main:addMovableFrame()
        :setPosition(2,3)
        :setSize(sizex or 30,sizey or 12)
        :setBackground(colors.black)
        :setShadow(colors.black)
        :setBorder(colors.gray, "left", "right", "bottom")
    
    f:addLabel()
        :setSize("parent.w-2", 1)
        :setPosition(2, 1)
        :setForeground(colors.white)
        :setText(" "..title.." ")
        :setTextAlign("center")

    local prg = f:addProgram()
        :onDone(function(self, err)
            self:getParent():setZIndex(-1)
            self:getParent():removeChildren()
            self:getParent():remove()
            processes[pId] = nil
        end)
    
    prg:setPosition(2, 2)
    prg:setSize("parent.w-2","parent.h-2")

    prg:execute(path or "./rom/programs/shell.lua")

    close_button = f:addButton()
        :setSize(3, 1)
        :setText("x")
        :setBackground(colors.red)
        :setForeground(colors.white)
        :setPosition("parent.w", 1)
        :onClick(function(self,event,button,x,y)
            self:getParent():setZIndex(-1)
            self:getParent():removeChildren()
            self:getParent():remove()
            term.setCursorBlink(false)
            processes[pId] = nil
        end)
    
    if resizable == true then
        resize_button = f:addButton()
            :setSize(3,1)
            :setText("\18")
            :setBackground(colors.black)
            :setForeground(colors.white)
            :setPosition("parent.w-1",1)
            :onClick(function(self,event,button,cx,cy)
                if event == "mouse_click" and button == 1 then
                    if self:getParent():getWidth() == Wterm+2 and self:getParent():getHeight() == Hterm then
                        self:getParent():animatePosition(5,5,0.1)
                        self:getParent():animateSize(30,12,0.1)
                        res:show()
                    else
                        self:getParent():animatePosition(0,2,0.1)
                        self:getParent():animateSize(Wterm+2,Hterm,0.1)
                        res:hide()
                    end
                end
            end)
            
        res = f:addButton()
            :setPosition("parent.w","parent.h")
            :setSize(1,1)
            :setText('\127')
            :setForeground(colors.lightGray)
            :setBackground(colors.black)
            :setZIndex(100)
            :onDrag(function(self, event, btn, xOffset, yOffset)
                local minW = 30
                local minH = 12
                local maxW = main:getWidth()
                local maxH = main:getHeight()
                local fw,fh = self:getParent():getSize()
                local wOff, hOff = fw,fh
                if (fw+xOffset-1>=minW) and (fw+xOffset-1<=maxW) then
                    wOff = fw+xOffset-1
                end
                if (fh+yOffset-1>=minH) and (fh+yOffset-1<=maxH) then
                    hOff = fh+yOffset-1
                end
                self:getParent():setSize(wOff,hOff)
            end)
    end

    if btstyle == 'large' then
        close_button:setSize(3, 1)
        if resizable == true then
            resize_button:setSize(3, 1)
        end

        close_button:setText("x")
        if resizable == true then
            resize_button:setText("\18")
        end

        if resizable == true then
            resize_button:setBackground(colors.black)
            resize_button:setForeground(colors.white)
        end

        close_button:setBackground(colors.red)
        close_button:setForeground(colors.white)

        close_button:setPosition(2, 1)
        if resizable == true then
            resize_button:setPosition(5,1)
        end
    elseif btstyle == 'small' then
        close_button:setSize(1, 1)
        if resizable == true then
            resize_button:setSize(1, 1)
        end

        close_button:setText("\7")
        if resizable == true then
            resize_button:setText("\7")
        end

        if resizable == true then
            resize_button:setBackground(colors.black)
            resize_button:setForeground(colors.green)
        end

        close_button:setBackground(colors.black)
        close_button:setForeground(colors.red)

        close_button:setPosition(2, 1)
        if resizable == true then
            resize_button:setPosition(3,1)
        end
    end
    
    processes[pId] = f
    return f
end

function notifications(title,description,extandable,button,color,action,actiondata)

    file = fs.open('./Data/telegramnotif.conf','r')
    telegramnotif = tostring(file.readAll())
    file.close()
    file = fs.open('./Data/telegrambotid.conf','r')
    telegrambotid = tostring(file.readAll())
    file.close()
    file = fs.open('./Data/telegramchatid.conf','r')
    telegramchatid = tostring(file.readAll())
    file.close()

    if telegramnotif == "yes" then
        http.get('https://api.telegram.org/bot'..telegrambotid..'/sendMessage?chat_id='..telegramchatid..'&text='..textutils.urlEncode(title..'\n'..description))
    end

    notif_title:setText(title)
    notif_desc:setText(description)
    notif_frame:animatePosition(Wterm-29,3,0.2)
    if speakerSide ~= nil and playsoundnotif == 'yes' then
        peripheral.wrap(speakerSide).playNote('banjo')
    end
    if extandable == true then
        notif_expand_bt:show()
    else
        notif_expand_bt:hide()
        notif_expand = false
    end
    if action == 'FtpRequest' and button == true then
        notif_expand_bt:hide()
        notif_frame:setSize(29,5)
        notif_expand = true
        notif_act_bt_ftp:setBackground(color)
        notif_act_bt_startup:hide()
        notif_act_bt_ftp:show()
        notif_act_bt_ftp:onClick(function()
            local file = fs.open(actiondata[2],'w+')
            file.write(actiondata[1])
            file.close()
            notif_frame:animatePosition(Wterm+1,3,0.2)
        end)
    elseif action == 'OpenProgram' and button == true then
        notif_expand_bt:hide()
        notif_act_bt_startup:show()
        notif_act_bt_ftp:hide()
        notif_frame:setSize(29,5)
        notif_expand = true
        notif_act_bt_startup:setBackground(color)
        notif_act_bt_startup:onClick(function()
            openProgram(actiondata[1],actiondata[2],actiondata[3],actiondata[4],actiondata[5],actiondata[6])
            notif_frame:animatePosition(Wterm+1,3,0.2)
        end)
    elseif action == 'FtpError' and button == true then
        notif_expand_bt:hide()
        notif_act_bt_startup:show()
        notif_act_bt_ftp:hide()
        notif_frame:setSize(29,5)
        notif_expand = true
        notif_act_bt_startup:setBackground(color)
        notif_act_bt_startup:onClick(function()
            local file = fs.open('./Data/settingdefault.conf','w+')
            file.write(actiondata[1])
            file.close()
            openProgram('./Devos/settings.lua','Settings',true,"parent.w/2","parent.h/2",false)
            notif_frame:animatePosition(Wterm+1,3,0.2)
        end)
    else
        notif_act_bt_startup:hide()
        notif_act_bt_ftp:hide()
    end
end

if startnotif == 'yes' then
    notifications('Started !','the os started !',false,true,colors.blue,'OpenProgram',{'./Devos/settings.lua','Settings',true,"parent.w/2","parent.h/2",false})
end

local function refresh()
    while true do
        id,msg = rednet.receive()
        if msg == "FTP" then
            local file = fs.open('./Data/allowftp.conf','r')
            local content = file.readAll()
            if content == 'yes' or content == 'only x times' then
                rednet.send(id,'bW9yZSBJbmZv')
                local fileT = fs.open('./Data/ftptime.conf','r')
                local contentT = fileT.readAll()
                fileT.close()
                contentT = tonumber(contentT) - 1
                if contentT == 0 and content == 'only x times' then
                    local fileT = fs.open('./Data/allowftp.conf','w+')
                    fileT.write('no')
                    fileT.close()
                else
                    local fileT = fs.open('./Data/ftptime.conf','w+')
                    fileT.write(contentT)
                    fileT.close()
                end
                for i = 1,100 do
                    lid,lcontent = rednet.receive()
                    if lid == id then
                        notifications('FTP',id..' want to send : '..lcontent[1],false,true,colors.green,'FtpRequest',{lcontent[2],lcontent[3]})
                        break
                    end
                end
            else
                rednet.send(id,'bW9yZSBJbmZv')
                notifications('FTP - Error','your FTP is disabled !',false,false)
            end
            file.close()
        end
        sleep(0.1)
    end
end

local function key_handler()
    while true do
        if basalt.isKeyDown(keys.leftAlt) then
            if hiden == true then
                open_menu()
                open_bookshelf()
                while true do
                    if not basalt.isKeyDown(keys.leftAlt) then
                        break
                    end
                    sleep(0.1)
                end
            else
                close_menu()
                close_bookshelf()
                while true do
                    if not basalt.isKeyDown(keys.leftAlt) then
                        break
                    end
                    sleep(0.1)
                end
            end
        end
        os.sleep(0.1)
    end
  end

topbar = main:addFrame()
    :setPosition(1,1)
    :setSize("parent.w",1)
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :setZIndex(3000)

local menu_control = topbar:addButton()
    :setPosition(1,1)
    :setSize(1,1)
    :setText("\4")
    :setBackground(colors.gray)
    :setForeground(colors.lightGray)
    :onClick(function()
        if hiden == true then
            open_menu()
        else
            close_menu()
            close_bookshelf()
        end
    end)

menu = main:addFrame()
    :setPosition(-7,3)
    :setSize(5,19)
    :setBackground(colors.gray)
    :setForeground(colors.white)
    :setZIndex(3000)
    :setShadow(colors.black)

local bookshelf = main:addList()
    :setPosition(-100,3)
    :setSize(20,19)
    :setZIndex(2999)
    :addItem(' ')
    :setShadow(colors.black)

global_task = nil

function close_menu()
    menu:animatePosition(-8,3,0.2)
    close_bookshelf()
    hiden = true
end

function open_menu()
    menu:animatePosition(2,3,0.2)
    hiden = false
end

function close_bookshelf()
    bookshelf:animatePosition(-100,3,0.2)
    bookshelf_hidden = false
end

function open_bookshelf()
    bookshelf:animatePosition(8,3,0.2)
    bookshelf_hidden = true
    bookshelf:clear()
    local filetree = fs.list('Program')
    for i in ipairs(filetree) do
        if filetree[i] ~= '.keep' then
            bookshelf:addItem(filetree[i])
        end
    end
end

bookshelf:onSelect(function(self, event, item)
    local index = self:getItemIndex()
    local name = self:getItem(index).text
    if name == ' ' then
        local nul = nil
    else
        if fs.find('Program/'..name) then
            close_bookshelf()
            self:selectItem(1)
            local file = fs.open('Program/'..name,'r')
            local content = file.readAll()
            file.close()
            if string.find(content,'--@Devos_not_resizable') then
                openProgram('Program/'..name,name,false,"parent.w/2","parent.h/2",false)
            else
                openProgram('Program/'..name,name,true,"parent.w/2","parent.h/2",false)
            end
            close_menu()
        end
    end
    self:selectItem(1)
end)

menu:addButton()
    :setPosition(2,2)
    :setSize(3,3)
    :setText("\174")
    :setBackground(colors.yellow)
    :setForeground(colors.black)
    :onClick(function()
        openProgram('./Devos/sys32/explorer','Explorer',false,"parent.w/2","parent.h/2",false)
        close_menu()
    end)

menu:addButton()
    :setPosition(2,6)
    :setSize(3,3)
    :setText(">")
    :setBackground(colors.white)
    :setForeground(colors.black)
    :onClick(function()
        openProgram('./rom/programs/shell.lua','Terminal',true,"parent.w/2","parent.h/2",false)
        close_menu()
    end)

menu:addButton()
    :setPosition(2,10)
    :setSize(3,3)
    :setText("\164")
    :setBackground(colors.lightGray)
    :setForeground(colors.black)
    :onClick(function()
        openProgram('./Devos/settings.lua','Settings',true,"parent.w/2","parent.h/2",false)
        close_menu()
    end)

menu:addButton()
    :setPosition(2,14)
    :setSize(3,3)
    :setText("\35")
    :setBackground(colors.purple)
    :setForeground(colors.black)
    :onClick(function()
        if bookshelf_hidden == true then
            close_bookshelf()
        else
            open_bookshelf()
        end
    end)

shutdownopt = menu:addFrame()
    :setPosition(2,18)
    :setSize(3,1)
    :setForeground(colors.gray)
    :setBackground(colors.gray)

shutdownopt:addButton()
    :setPosition(1,1)
    :setText("\7")
    :setSize(1,1)
    :setBackground(colors.orange)
    :setForeground(colors.black)
    :onClick(function()
        os.reboot()
    end)

shutdownopt:addButton()
    :setPosition(3,1)
    :setText("\7")
    :setSize(1,1)
    :setBackground(colors.red)
    :setForeground(colors.black)
    :onClick(function()
        os.shutdown()
    end)

topbar:addLabel():setText('BETA'):setForeground(colors.lightGray):setPosition("parent.w-4",1)
-- main:addLabel():setText('ALPHA'):setForeground(colors.lightGray):setPosition("parent.w-5",1)

main:addThread()
    :start(refresh)

main:addThread()
    :start(refresh_settings)

main:addThread()
    :start(key_handler)

function notif_handler()
    while true do
        notifdata = fs.open('./Devos/sys32/temp/notifdata','r')
        notifdatacontent = notifdata.readAll()
        notifdata.close()

        if notifdatacontent ~= '' then
            notifdata = fs.open('./Devos/sys32/temp/notifdata','w+')
            notifdata.write('')
            notifdata.close()
            local text = notifdatacontent

            -- Fonction pour séparer correctement en respectant les structures
            local function split_text(input)
                local result = {}
                local current = ""
                local i = 1
                local inside_structure = false
                local structure_char = nil -- Pour suivre si on est dans une table, guillemets simples ou doubles

                while i <= #input do
                    local char = input:sub(i, i)
                    local next_two = input:sub(i, i + 2) -- Vérifie les 3 prochains caractères pour "%20"

                    -- Détecter le début ou la fin d'une structure
                    if (char == "{" or char == "\"" or char == "'") and not inside_structure then
                        inside_structure = true
                        structure_char = char
                    elseif char == structure_char and inside_structure then
                        inside_structure = false
                        structure_char = nil
                    elseif char == "}" and inside_structure and structure_char == "{" then
                        inside_structure = false
                    end

                    -- Si on rencontre "%20" hors des structures, on ajoute la partie courante
                    if not inside_structure and next_two == "%20" then
                        table.insert(result, current)
                        current = ""
                        i = i + 2 -- Sauter le délimiteur
                    else
                        current = current .. char
                    end

                    i = i + 1
                end

                -- Ajouter la dernière partie
                if current ~= "" then
                    table.insert(result, current)
                end

                return result
            end

            -- Appeler la fonction et afficher les résultats
            local parts = split_text(text)
            notifications(parts[1],parts[2],false,false)
        end
        sleep(0.1)
    end
end

function program_handler()
    while true do
        notifdata = fs.open('./Devos/sys32/temp/programdata','r')
        notifdatacontent = notifdata.readAll()
        notifdata.close()

        if notifdatacontent ~= '' then
            notifdata = fs.open('./Devos/sys32/temp/programdata','w+')
            notifdata.write('')
            notifdata.close()
            local text = notifdatacontent

            -- Fonction pour séparer correctement en respectant les structures
            local function split_text(input)
                local result = {}
                local current = ""
                local i = 1
                local inside_structure = false
                local structure_char = nil -- Pour suivre si on est dans une table, guillemets simples ou doubles

                while i <= #input do
                    local char = input:sub(i, i)
                    local next_two = input:sub(i, i + 2) -- Vérifie les 3 prochains caractères pour "%20"

                    -- Détecter le début ou la fin d'une structure
                    if (char == "{" or char == "\"" or char == "'") and not inside_structure then
                        inside_structure = true
                        structure_char = char
                    elseif char == structure_char and inside_structure then
                        inside_structure = false
                        structure_char = nil
                    elseif char == "}" and inside_structure and structure_char == "{" then
                        inside_structure = false
                    end

                    -- Si on rencontre "%20" hors des structures, on ajoute la partie courante
                    if not inside_structure and next_two == "%20" then
                        table.insert(result, current)
                        current = ""
                        i = i + 2 -- Sauter le délimiteur
                    else
                        current = current .. char
                    end

                    i = i + 1
                end

                -- Ajouter la dernière partie
                if current ~= "" then
                    table.insert(result, current)
                end

                return result
            end

            -- Appeler la fonction et afficher les résultats
            local parts = split_text(text)

            function file_exists(name)
                local f=io.open(name,"r")
                if f~=nil then io.close(f) return true else return false end
            end

            if file_exists(parts[1]) then
                local file = fs.open(parts[1],'r')
                local content = file.readAll()
                file.close()
                if string.find(content,'--@Devos_not_resizable') then
                    openProgram(parts[1],parts[2],false,parts[4],parts[5],false)
                else
                    if parts[3] == 'true' then
                        openProgram(parts[1],parts[2],true,parts[4],parts[5],false)
                    else
                        openProgram(parts[1],parts[2],false,parts[4],parts[5],false)
                    end
                end
            end
        end
        sleep(0.1)
    end
end

main:addThread()
    :start(notif_handler)

main:addThread()
    :start(program_handler)

basalt.autoUpdate()
