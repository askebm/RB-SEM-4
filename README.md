# Skabelon til rapportskrivning

Main.tex er hovedfilen der skal compiles, alle subfiler kan også compiles for sig.

Layout.tex indeholder preamblen
Formalier.tex indeholder en række commands der gør at sådan noget som vejleder navn og afleverings dato bliver skrevet konsekvent

I hver mappe skal der ligge en fil Path.tex der indeholder 
`\providecommand{\main}{<Sti til roden af roden af projekt mappen>}`

Alle filstier skal angives som absolutte filstier fra roden af projektmappen eg. `\includegraphics{\main/afsnit/asfnit1/billeder/Mig.png}`

Ved anvendelse af Bibtex compile i følgende rækkefølge: pdflatex, bibtax, pdflatex, pdflatex



Ved anvendelse af inkscape huske flag -shell-escape

## Billeder i rapporten

Anvend enten [inkscape](https://inkscape.org/), hvor svg filer herfra kan inkluderes med
 `\includesvg[images/]{image}` trailing `/` er vigtigt!

Det er vigtigt at inkscape ligger i din path for at dette virker og at latex kompileres med 
flaget `--shell-escape`


Eller anvend [tikzit](https://tikzit.github.io/) til at generere et tikzpicture.

At skrive tikz direkte er selvfølgelig også okay.

Undgå at anvende PNG, JPG og JPEG, da vektorgrafik(svg,pdf) fortrækkes og ser meget bedre ud.

### Matlab plot

Lad være med at bruge EPS filer herfra, da de ikke har samme font. Anvend da istedet 
[Plot2Latex](https://se.mathworks.com/matlabcentral/fileexchange/52700-plot2latex)


