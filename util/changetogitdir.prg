
***************************************************************************************
function change_to_gitdir()

local curdir:=curdir()

    while( empty(directory(".git","HD")) )
        //A git diff-ek akkor működnek,
        //ha a git tree gyökeréből vannak indítva.
        //Hogy ne kelljen folyton váltogatni a directorykat,
        //automatikusan ráállunk a git tree gyökerére.
        //A Linuxon a workdir a programra lokális,
        //tehát kilépés után az eredeti helyen leszünk.
    
        if( 0!=dirchange("..") .or. empty(curdir())  )
            //Az a furcsa, 
            //hogy Linuxon a /-ben cd .. sikeresnek számít, 
            //holott nyilvánvalóan nem lehet feljebb menni

            if( 2>alert(curdir+";;Not in a git working tree!",{"Quit","Create git repo"}))
                quit
            else
                if( dirchange(curdir)==0 )
                    create_repo()
                end
            end
        end
    end

    if( empty(output_of("git branch")) )
        //alert("no branch")
        //"git init" utan, de meg az elso commit elott
        //ha igy tovabmenne, elszallna a program
        //ezert kell legyen legalabb egy commit
        create_repo()
    end

    if( !empty(debug()) )
        ?? ".git directory found in",curdir();?
    end
    setcaption(curdir())

***************************************************************************************
