

********************************************************************************************
function local_profile()

#ifdef _WINDOWS_
    if( file(".git\local\profile.bat") )
        run( ".git\local\profile.bat" )
    end

#else
    if( file(".git/local/profile") )
        run( ". .git/local/profile" )
    end
#endif

********************************************************************************************
