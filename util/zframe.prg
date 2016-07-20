
#include "box.ch"

#define RECT(x) x:top,x:left,x:bottom,x:right

***************************************************************************************
class zframe(object)

    attrib  top
    attrib  left
    attrib  bottom
    attrib  right

    method  initialize
    
    attrib  zbstack         //zbrowse-okat tárol
    method  zbrowse         {|this|atail(this:zbstack)}
    method  pop
    method  push
    method  set             {|t,x|t:pop,t:push(x)}
  
    method  seltext         :zbrowse:seltext   
    method  header1         :zbrowse:header1      //header1
    method  color1          :zbrowse:color1       //header1 színe
    method  header2         :zbrowse:header2 
    method  color2          :zbrowse:color2  

    method  draw
    method  loop
    

***************************************************************************************
static function zframe.initialize(this,t:=0,l:=0,b:=maxrow(),r:=maxcol())
    this:top:=t
    this:left:=l
    this:bottom:=b
    this:right:=r
    this:zbstack:={}
    return this


***************************************************************************************
static function zframe.pop(this)
local len:=len(this:zbstack)
    if(len>0)
        this:zbstack::asize(len-1)
    end


***************************************************************************************
static function zframe.push(this,zb)
    if( valtype(zb)=="C" )
        zb:=zbrowseNew(zb)
    end
    zb:top:=this:top+5
    zb:left:=this:left+1
    zb:bottom:=this:bottom-1
    zb:right:=this:right-1
    this:zbstack::aadd(zb)
    return zb


***************************************************************************************
static function zframe.draw(this)
local sep:=B_SD4+replicate(B_HS,this:right-this:left-1)+B_SD6
    @ this:top,this:left  clear to  this:bottom, this:right 
    @ RECT(this)  box  B_SINGLE_DOUBLE
    @ this:top+1,this:left+2  say this:header1  color this:color1
    @ this:top+2,this:left    say sep
    @ this:top+3,this:left+2  say this:header2  color this:color2
    @ this:top+4,this:left    say sep


***************************************************************************************
static function zframe.loop(this)
local cursor :=setcursor()
local screen :=savescreen(RECT(this))
local zb

    while( NIL!=(zb:=this:zbrowse) )    // amíg nem üres a stack
        this:draw
        zb:loop
        if( zb:topush!=NIL )
            this:push(zb:topush)        // stack nő
        elseif( zb:toset!=NIL )
            this:set(zb:toset)          // stack topja cserélődik
        else
            this:pop                    // stack csökken 
        end
        zb:topush:=NIL                  // beállítások törlődnek
        zb:toset:=NIL                   // beállítások törlődnek
    end

    restscreen(RECT(this),screen)
    setcursor(cursor)

***************************************************************************************


    