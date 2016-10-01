
#include <cccapi.h>

void _clp_removecr(int argno)
{
    CCC_PROLOG("removecr",1);
    char *x=_parb(1);
    int lenx=_parblen(1);

    char *y=binaryl(lenx);
    int leny=0;
    
    for(int i=0; i<lenx; i++)
    {
        if( x[i]!=13  )
        {
            y[leny++]=x[i];
        }
    }

    _retblen(y,leny);
    CCC_EPILOG();
}



