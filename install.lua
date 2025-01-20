local install = {
    {"https://raw.githubusercontent.com/ShadowHedgehog76/Devos/refs/heads/main/OS/startup.lua","startup.lua"},

    {"https://raw.githubusercontent.com/ShadowHedgehog76/Devos/refs/heads/main/OS/Devos/desktop.lua","Devos/desktop.lua"},
    {"https://raw.githubusercontent.com/ShadowHedgehog76/Devos/refs/heads/main/OS/Devos/edit.lua","Devos/edit.lua"},
    {"https://raw.githubusercontent.com/ShadowHedgehog76/Devos/refs/heads/main/OS/Devos/settings.lua","Devos/settings.lua"},
    {"https://raw.githubusercontent.com/ShadowHedgehog76/Devos/refs/heads/main/OS/Devos/sys32/basalt","Devos/sys32/basalt"},
    {"https://raw.githubusercontent.com/ShadowHedgehog76/Devos/refs/heads/main/OS/Devos/sys32/base64","Devos/sys32/base64"},
    {"https://raw.githubusercontent.com/ShadowHedgehog76/Devos/refs/heads/main/OS/Devos/sys32/deamon","Devos/sys32/deamon"},
    {"https://raw.githubusercontent.com/ShadowHedgehog76/Devos/refs/heads/main/OS/Devos/sys32/explorer","Devos/sys32/explorer"},
    {"https://raw.githubusercontent.com/ShadowHedgehog76/Devos/refs/heads/main/OS/Devos/sys32/Ldev","Devos/sys32/Ldev"},
    {"https://raw.githubusercontent.com/ShadowHedgehog76/Devos/refs/heads/main/OS/Devos/sys32/lex.lua","Devos/sys32/lex.lua"},
    {"https://raw.githubusercontent.com/ShadowHedgehog76/Devos/refs/heads/main/OS/Devos/sys32/temp/notifdata","Devos/sys32/temp/notifdata"},
    {"https://raw.githubusercontent.com/ShadowHedgehog76/Devos/refs/heads/main/OS/Devos/sys32/temp/programdata","Devos/sys32/temp/programdata"},

    {"https://raw.githubusercontent.com/ShadowHedgehog76/Devos/refs/heads/main/OS/Program/firewolf.lua","Program/firewolf.lua"},
    {"https://raw.githubusercontent.com/ShadowHedgehog76/Devos/refs/heads/main/OS/Program/modemshark.lua","Program/modemshark.lua"},
    {"https://raw.githubusercontent.com/ShadowHedgehog76/Devos/refs/heads/main/OS/Program/wm.lua","Program/wm.lua"},

    {"https://github.com/ShadowHedgehog76/Devos/blob/main/OS/Data/LICENSES.txt","Data/LICENSES.txt"},
    {"https://github.com/ShadowHedgehog76/Devos/blob/main/OS/Data/allowftp.conf","Data/allowftp.conf"},
    {"https://github.com/ShadowHedgehog76/Devos/blob/main/OS/Data/ftptime.conf","Data/ftptime.conf"},
    {"https://github.com/ShadowHedgehog76/Devos/blob/main/OS/Data/playsound.conf","Data/playsound.conf"},
    {"https://github.com/ShadowHedgehog76/Devos/blob/main/OS/Data/settingdefault.conf","Data/settingdefault.conf"},
    {"https://github.com/ShadowHedgehog76/Devos/blob/main/OS/Data/startupnotif.conf","Data/startupnotif.conf"},
    {"https://github.com/ShadowHedgehog76/Devos/blob/main/OS/Data/telegrambotid.conf","Data/telegrambotid.conf"},
    {"https://github.com/ShadowHedgehog76/Devos/blob/main/OS/Data/telegramchatid.conf","Data/telegramchatid.conf"},
    {"https://github.com/ShadowHedgehog76/Devos/blob/main/OS/Data/telegramnotif.conf","Data/telegramnotif.conf"},
    {"https://github.com/ShadowHedgehog76/Devos/blob/main/OS/Data/titlebarstylebt.conf","Data/titlebarstylebt.conf"},
    {"https://github.com/ShadowHedgehog76/Devos/blob/main/OS/Data/usenewedit.conf","Data/usenewedit.conf"},
    {"https://github.com/ShadowHedgehog76/Devos/blob/main/OS/Data/version.conf","Data/version.conf"},
}

shell.run("mkdir Devos")
shell.run("mkdir Devos/sys32")
shell.run("mkdir Devos/sys32/temp")
shell.run("mkdir Data")
shell.run("mkdir Program")

file = fs.open("Program/.keep","w")
file.write("This file is used to keep the Program folder")
file.close()

for i = 1, #install do
    shell.run("wget "..install[i][1].." "..install[i][2])
end
