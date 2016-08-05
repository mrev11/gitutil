


*************************************************************************************
function fn_escape(fn)

//fajlneveket olyan alakra hozza, 
//hogy be lehessen irni a parancssorba

    fn::=alltrim
    fn::=unquote
    fn::=strtran(" ","\ ")

    return fn

*************************************************************************************
function unquote(fn)

//némelyik git funkció
//idézőjelben adja a fájlneveket
//pl. git status
//itt leszedem az idézőjeleket

    if( left(fn,1)=='"' .and. right(fn,1)=='"' )
        fn:=fn[2..len(fn)-1]
        fn::=strtran('" -> "'," -> ")  //átnevezések közepe!
    end
    
    
    //alert(fn)

    return fn


*************************************************************************************

    