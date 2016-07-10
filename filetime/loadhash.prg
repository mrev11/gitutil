
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


**************************************************************************************
function loadhash()

local hash:=simplehashNew()

local ftdir, n
local fd,rl,line,hdata

    
    ftdir:=directory(".FILETIME_*")

    for n:=1 to len(ftdir)
        if( fext0(ftdir[n][F_NAME])=="bak" )
            loop
        end
    
        ?? "found", ftdir[n][F_NAME];?

        fd:=fopen(ftdir[n][F_NAME])
        if( fd<0 )
            ?? "fopen failed", ftdir[n][F_NAME], ferror();?
            quit
        end

        rl:=readlineNew(fd)
        while( NIL!=(line:=rl:readline) )
            line::=bin2str
            line::=strtran(chr(10),"")
            line::=split(" ")  //{sha1,datetime,fspec}
            hdata:=hash[line[1]]
            if( hdata==NIL .or. hdata[2]>line[2] )
                hash[line[1]]:=line
            end
        end
        
        fclose(fd)
    end

    return hash

**************************************************************************************


    