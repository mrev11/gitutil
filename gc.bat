@echo off

::1) törli az összes .gitignored fájlt
::2) átlinkeli az .git/local-ban levő scripteket
::
::
:: Az a koncepció, .git/local-ban egyéni scriptek vannak
:: amelyek mind ignoráltak, ezért  git clean -fXd törli őket
:: az objectekkel es exekkel együtt, de csak a gyökérben
:: levő linkjüket, a .git/local-ban levő tényleges fájlt nem.
:: A második lépésben aztán újra belinkelődnek a gyökérbe.
 
:: Illetve általánosabb: végrehajtja .git/local/profile-t,
:: ami azt csinál, amit akar, ha akar linkel.

git clean -fXd  2>&1 >NUL


::if [ -f .git/local/profile  ];then
::   . .git/local/profile
::fi


