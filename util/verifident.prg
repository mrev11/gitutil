

//ellenorzi, hogy be van-e allitva a user name/email-je
//ha nincsenek meg a beallitasok, figyelmeztet, es kilep
//
//ha nincs name/email, akkor a git nem enged commitolni
//ha nem lehet commitolni, akkor az uj repoban nem jon letre branch
//ha nincs branch, akkor elszall a program
//tehat uj repo letrehozasa elott meg kell ezt hivni


function verif_ident()

local name:=output_of("git config --get user.name")
local email:=output_of("git config --get user.email")

    if( empty(name) .or. empty(email) )
        ?? <<MSG>>*** Please tell me who you are.

Run

  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"

to set your account's default identity.
Omit --global to set the identity only in this repository.
<<MSG>>
        quit

    else
        ?? "user.name  :", name
        ?? "user.email :", email
    end
