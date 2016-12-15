


//A Windows a teli-nyari ido kulonbseget csak akkor
//veszi figyelembe, ha be van allitva az automatikus
//ora-atallitas (automatic adjust).


function localtime2utctime(da,ti)
    return dati2ostime(da,ti)::gmtime2dati
    //windowson igy is lehetne:
    //return __localtimetofiletime(da,ti)::__filetimetoutctime


function utctime2localtime(da,ti)
local sec1:=dati2sec(da,ti)
local dati:=localtime2utctime(da,ti)
local sec2:=dati2sec(dati[1],dati[2])
    return sec2dati(sec1+(sec1-sec2))
    
