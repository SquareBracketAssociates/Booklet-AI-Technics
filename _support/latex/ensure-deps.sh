#!/bin/bash

xargs tlmgr install <<DEPS
    collection-fontsrecommended
    collection-mathscience

    algorithm2e
    ctablestack
    environ
    filehook
    fira
	fontaxes
    fontspec
    footmisc
    gentium-tug
    graphics
    hyphen-english
    ifoddpage
    import
    listings
    luatexbase
    mdframed
    memoir
    multirow
    opensans
    pgf
    polyglossia
    ragged2e
    relsize
    slantsc
    tcolorbox
    textcase
    tools
    trimspaces
    ulem
    varwidth
    xcolor
    xtab
	zref-abspage
DEPS
