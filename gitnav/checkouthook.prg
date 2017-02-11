


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

// kerdes lehet,
// hogy mitol mukodik Windowson a bash szintaktikaju script
// nem tudom, mitol, de az ellenorzes mutatja, hogy mukodik
