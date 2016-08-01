//zbrowse.prg

#include "box.ch"
#include "inkey.ch"

#define RECT(x) x:top,x:left,x:bottom,x:right


*************************************************************************************
class zbrowse(zedit)
    method  initialize
    method  seltext         //aktuális sor szövege
    method  add_shortcut    //berak egy shortcut-ot
    method  eval_shortcut   //végrehajtja a key-hez rendelt shortcut-ot (ha létezik)
    method  loop            //működteti a zbrowse-t (inkey ciklus)
    method  help
    
    attrib  shortcut        //{{key,block,text},...}

    attrib  header1         //csak akkor érdekes, ha zframe-ben van
    attrib  header2         //csak akkor érdekes, ha zframe-ben van
    attrib  color1          //csak akkor érdekes, ha zframe-ben van
    attrib  color2          //csak akkor érdekes, ha zframe-ben van

    attrib  topush          //csak akkor érdekes, ha zframe-ben van
    attrib  toset           //csak akkor érdekes, ha zframe-ben van


*************************************************************************************
static function zbrowse.initialize(this,txt,t,l,b,r)
    this:(zedit)initialize(txt,t,l,b,r)

    this:shortcut:={} //{{key,block},...}

    this:header1:=""; this:color1:="gr+/n"
    this:header2:=""; this:color2:="w+/n"
    
    return this    


*************************************************************************************
static function zbrowse.seltext(this)  //aktuális sor szövege
    return this:atxt[this:actrow]

        
*************************************************************************************
static function zbrowse.add_shortcut(this,key,block,help)
    aadd(this:shortcut,{key,block,help})


*************************************************************************************
static function zbrowse.eval_shortcut(this,key)
local x:=ascan(this:shortcut,{|s|s[1]==key})

    if( x>0 )
        dispend()
        key:=eval(this:shortcut[x][2],this)
        if(key==NIL)
            key:=99999
        end
    end
    return key


*************************************************************************************
static function zbrowse.loop(this)

local cursor:=setcursor(0)
local screen:=savescreen(RECT(this))
local key

    this:display

    while(.t.)

        setpos(this:top+this:winrow,this:left+this:wincol)
        
        inverserect(row(),this:left,row(),this:right)
        dispend()
        key:=inkey(0)
        key:=this:eval_shortcut(key)
        dispbegin()
        inverserect(row(),this:left,row(),this:right)

        
        if( key==K_ESC )
            exit

        elseif( key==K_DOWN )    
            this:down

        elseif( key==K_UP )    
            this:up

        elseif( key==K_PGDN )    
            this:pagedown

        elseif( key==K_PGUP )    
            this:pageup

        elseif( key==K_CTRL_PGDN )    
            this:ctrlpgdn

        elseif( key==K_CTRL_PGUP )    
            this:ctrlpgup

        elseif( key==K_RIGHT )
            this:wincol:=this:width-1  
            this:moveright

        elseif( key==K_LEFT )    
            this:wincol:=0  
            this:moveleft  

        elseif( key==K_HOME )    
            this:home  



        elseif( key==K_F3 )
            dispend()    
            this:search

        elseif( key==K_ALT_F3 )    
            dispend()    
            this:search("i")
 
        elseif( key==K_SH_F3 )    
            this:searchagain

        elseif( key==K_CTRL_F3 )    
            this:searchagain("p")

        end
    end

    restscreen(RECT(this),screen)
    setcursor(cursor)
    dispend()

*************************************************************************************
static function zbrowse.help(this)

local menu:={},item
local wkey:=0
local wtxt:=0
local n,sc
local t,l,b,r
local ch,result
local screen,cr,cc

    for n:=1 to len(this:shortcut)
        sc:=this:shortcut[n]
        asize(sc,3)
        wkey::=max(len(inkeycode2name(sc[1])))
        wtxt::=max(len(sc[3]))
    next
    
    for n:=1 to len(this:shortcut)
        sc:=this:shortcut[n]
        item:=sc[1]::inkeycode2name::padr(wkey)+": "
        if(NIL!=sc[3])
            item+=sc[3]
            menu::aadd(item)
        end
    next
    
    if( empty(menu) )
        return 0
    end
    
    t:=this:top+1
    l:=(this:right-wkey-wtxt-6)::max(1)
    b:=(t+len(menu)::max(4)+1)::min(maxrow()-1)
    r:=(l+wkey+wtxt+4)::min(maxcol()-1)
    
    cr:=row()
    cc:=col()
    screen:=drawbox(t,l,b,r)
    ch:=achoice(t+1,l+1,b-1,r-1,menu)
    restscreen(t,l,b,r,screen)
    if( ch>0 )
        result:=eval(this:shortcut[ch][2],this)
    end
    setpos(cr,cc) //nem szabad változnia!
    return result
    

*************************************************************************************
