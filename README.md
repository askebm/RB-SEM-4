Skabelon til rapportskrivning

Main.tex er hovedfilen der skal compiles, alle subfiler kan også compiles for sig.

Layout.tex indeholder preamblen
Formalier.tex indeholder en række commands der gør at sådan noget som vejleder navn og afleverings dato bliver skrevet konsekvent

I hver mappe skal der ligge en fil Path.txt der indeholder `\providecommand{\main}{<Sti til roden af roden af projekt mappen>}`

Alle filstier skal angives som absolutte filstier fra roden af projektmappen eg. `\includegraphics{\main/afsnit/asfnit1/billeder/Mig.png}`

Ved anvendelse af Bibtex compile i følgende rækkefølge: pdflatex, bibtax, pdflatex, pdflatex
Ved anvendelse af inkscape huske flag -shell-escape

