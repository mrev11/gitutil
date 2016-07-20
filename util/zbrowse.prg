//zbrowse.prg

#include "inkey.ch"

#define RECT(x) x:top,x:left,x:bottom,x:right


*************************************************************************************
class zbrowse(zedit)
    method  initialize
    method  seltext         //aktuális sor szövege
    method  add_shortcut    //berak egy shortcut-ot
    method  eval_shortcut   //végrehajtja a key-hez rendelt shortcut-ot (ha létezik)
    method  loop            //működteti a zbrowse-t (inkey ciklus)
    
    attrib  shortcut        //{{key,block},...}
    method  add_shortcut

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
static function zbrowse.add_shortcut(this,key,block)
    aadd(this:shortcut,{key,block})


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
        dispbegin()
        inverserect(row(),this:left,row(),this:right)
        
        key:=this:eval_shortcut(key)
        
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

    setcursor(cursor)
    restscreen(RECT(this),screen)
    dispend()

*************************************************************************************
