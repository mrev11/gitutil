
/*
 *  CCC - The Clipper to C++ Compiler
 *  Copyright (C) 2005 ComFirm BT.
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */


#include "directry.ch"

static xdir:={".","..",".git","objlin","ppo"}

static xext:={"exe","obj","o","ppo","lib","so","a",;
              "bak","tmp","nopack"} // excluded file AND DIR extensions
//            "zip","bz2","tar","gz",;



*****************************************************************************
function walktree(path:=".")    

local name,date,time,size,attr,ext
local n,d,d1:={}

    d:=directory(path+dirsep()+fullmask(),"D")
    
    for n:=1 to len(d)
        name:=d[n][F_NAME]
        date:=d[n][F_DATE]
        time:=d[n][F_TIME]
        size:=d[n][F_SIZE]
        attr:=d[n][F_ATTR]
        
        ext:=fext0(name)
        if( 0<ascan(xext,{|e|e==ext}) )
            loop
        end

        if( "D"$attr )
            if( 0==ascan(xdir,{|n|n==name}) )
                aadd(d1,name)
            end

        elseif( size<=0 .or. 1024*1024*4<size )
            //kihagy

        elseif( name[1..10]==".FILETIME_" )
            //kihagy

        elseif( name=="commit-message" )
            //kihagy

        elseif( empty(ext) .and. name[1..3]=="out" )
            //kihagy

        else
            procfile(path+dirsep()+name,date,time) //callback
        end
       
    next
   
    d:=NIL
    
    for n:=1 to len(d1)
        walktree(path+dirsep()+d1[n] )
    next


*****************************************************************************
