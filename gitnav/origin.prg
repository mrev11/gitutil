

function origin(branch)

//előveszi az origin commitid-jét
//nem találtam rá API-t, kiszedem a .git-ből

local fspec:=".git/refs/remotes/origin/"+branch 
local id:=memoread(fspec) //üres, ha nem létezik, végén egy LF

    return id::strtran(chr(10),"")
    