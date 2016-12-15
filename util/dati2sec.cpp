

#include <math.h>
#include <cccapi.h>

// sec nagysagrendje 11 decimalis (9 hexa) jegy,
// tehat: 
//  a double abrazolas megfelel
//  az int abrazolas nem felel meg
//  a long Linuxon jo volna, Windowson keves

//----------------------------------------------------------------------------
void _clp_dati2sec(int argno)
{
    CCC_PROLOG("dati2sec",2);
    str2bin(base+1);
    double sec=(double)_pard(1);
    char *time=_parb(2);
    if(_parblen(2)!=8)
    {
        ARGERROR();
    }
    unsigned int hour=0,minute=0,second=0; 
    sscanf(time,"%d:%d:%d",&hour,&minute,&second);
    sec=sec*24+hour;
    sec=sec*60+minute;
    sec=sec*60+second;
    _retnd(sec);
    CCC_EPILOG();
}

//----------------------------------------------------------------------------
void _clp_sec2dati(int argno)
{
    CCC_PROLOG("sec2dati",1);

    double sec=_parnd(1);
    unsigned second=sec-floor(sec/60.0)*60.0;
    sec=(sec-second)/60;
    unsigned minute=sec-floor(sec/60.0)*60.0;
    sec=(sec-minute)/60;
    unsigned hour=sec-floor(sec/24.0)*24.0;
    sec=(sec-hour)/24;
    char buf[32];
    sprintf(buf,"%02d:%02d:%02d",hour,minute,second);

    date(sec);
    stringnb(buf);
    array(2);
   _rettop();

    CCC_EPILOG();
}

//----------------------------------------------------------------------------

