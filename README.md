Created on June 10, 2018 to manage Netspective's Hugo based web sites

Use the Makefile for operating this repo, check all targets:

    make help

To run in test mode (local Hugo server), both of the following are equivalent:

    make
    make test

When PlantUML diagrams change (anytime *.plantuml files are updated):

    make generate-diagrams

Theme was added using

    mkdir themes
    cd themes
    git submodule add https://github.com/netspective/hugo-theme-default.git netspective

**NOTE: If [source theme](https://github.com/matcornic/hugo-theme-learn.git) changes, be sure to merge in the changes to [our theme](https://github.com/netspective/hugo-theme-default.git). Like this:

    make check-theme
    make update-theme
