


function setup_checkout_hook()

local hspec:=".git/hooks/post-checkout"
local script:=<<SCRIPT>>#!/bin/bash
echo 'Invoked post-checkout'
filetime-restore.exe
<<SCRIPT>>


    if( !file(hspec) )
        memowrit(hspec,script)
        chmod(hspec,0b111101101)  //755
        ?? "install "+hspec;?
    end

