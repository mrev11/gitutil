
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


static hash


*****************************************************************************
function main()

local outfile:=".FILETIME_"+username()
local bakfile:=outfile+".bak"
local hdata
local outarr:={},n

    set date format 'yyyy-mm-dd'
    
    if( !direxist(".git") )
        ?? "not a git repository";?
    elseif( repo_clean() )
        ?? 'working directory clean';?
        if( 0<ascan(argv(),{|a|a=='-f'}) )
            ?? "save forced";?
        else
            quit
        end
    end
    
    hash:=loadhash()

    walktree()
    
    hdata:=hash:firstvalue
    while(hdata!=NIL)
        if( len(hdata)>=4 .and. hdata[4] )
            //a letezoket kivalogatja
            outarr::aadd(hdata)
        end
        hdata:=hash:nextvalue
    end
    
    asort(outarr,,,{|x,y|sort(x,y)})


    frename(outfile,bakfile)
    set alternate on
    set alternate to (outfile)
    set console off

    for n:=1 to len(outarr)
        ?? outarr[n][1], outarr[n][2], outarr[n][3]::strtran('\','/'); ?
    next

    set alternate off
    set alternate to
    
    if( file(bakfile) )
        run( "diff "+bakfile+" "+outfile )
    end
    

*****************************************************************************
static function sort(x,y)
    if( x[2]==y[2] )
        return x[3]<y[3] //fspec (asc)
    end
    return x[2]>y[2] //datetime (desc)
    

*****************************************************************************
function procfile(fspec,date,time)  //callback

local x:=memoread(fspec,.t.)
local sha1:=x::removecr::crypto_sha1::crypto_bin2hex::bin2str
local hdata:=hash[sha1]
local utcdati:=localtime2utctime(date,time)
local dtime:=utcdati[1]::dtos+utcdati[2]+"-UTC"

    if( hdata==NIL )
        //hash[sha1]:=hdata:={sha1,dtime,fspec}
        hash[sha1]:=hdata:={sha1,dtime,fspec::strtran(" ","_")}
    elseif( dtime<hdata[2] )
        hdata[2]:=dtime
    end

    //jelzi, hogy letezik
    asize(hdata,4)
    hdata[4]:=.t.

//Megjegyzes: fspec::strtran(" ","_")
//  A filespecifikaciot nem hasznaljuk semmire,
//  a szokozoket tartalmazo filenevek zavarjak a split-et,
//  ezert legegyszerubb kiszedni a szokozoket,
//  amugy sem szerencses egzotikus fileneveket hasznalni.

*****************************************************************************
