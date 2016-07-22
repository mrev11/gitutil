
********************************************************************************************
function link_local()
local gitloc:=directory(".git/local/*"),n
    for n:=1 to len(gitloc)
        run( "ln -s .git/local/"+gitloc[n][1]+" ." )
    end

// Az a koncepció, .git/local-ban egyéni scriptek vannak
// amelyek mind ignoráltak, ezért  git clean -fXd törli őket
// az objectekkel és exekkel együtt, de csak a gyökérben
// levő linkjüket, a .git/local-ban levő tényleges fájlt nem.
// Most újra belinkelődnek a gyökérbe.


********************************************************************************************
