
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
    set date format 'yyyy-mm-dd'
    hash:=loadhash()
    walktree()


*****************************************************************************
function procfile(fspec,date,time) //callback

local x:=memoread(fspec,.t.)
local sha1:=x::removecr::crypto_sha1::crypto_bin2hex::bin2str
local hdata:=hash[sha1]
local da,ti

    if( NIL!=hdata .and. hdata[2]<dtos(date)+time )
        da:=hdata[2][1..8]::stod
        ti:=hdata[2][9..16]
        ?? date,time, " <- ", da,ti, fspec;?
        setfdati(fspec,da,ti)
    end


*****************************************************************************
