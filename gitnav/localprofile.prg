

********************************************************************************************
function local_profile()
    if( file(".git/local/profile") )
        run( ". .git/local/profile" )
    end


// Az a koncepció, .git/local-ban egyéni scriptek vannak
// amelyek mind ignoráltak, ezért  git clean -fXd törli őket
// az objectekkel és exekkel együtt, de csak a gyökérben
// levő linkjüket, a .git/local-ban levő tényleges fájlt nem.
// Most újra belinkelődnek a gyökérbe.

// Illetve általánosabb: végrehajtja .git/local/profile-t,
// ami azt csinál, amit akar.


********************************************************************************************
