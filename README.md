Created on June 10, 2018 to manage Netspective's Hugo based web sites

Theme was added using

    mkdir themes
    cd themes
    git submodule add https://github.com/netspective/hugo-theme-default.git netspective

**NOTE: If [source theme](https://github.com/matcornic/hugo-theme-learn.git) changes, be sure to merge in the changes to [our theme](https://github.com/netspective/hugo-theme-default.git). Like this:

    make check-theme
    make update-theme

Check out the Makefile and see its targets:

    make help

Use this to generate diagrams and graphdoc:

    make generate-diagrams generate-documents

Use this to clean up generated files:

    make clean

Check out the Makefile and use these common targets:

    Usage:
        make <target>

    Targets:
        default              Default is to run this in development mode for testing the website
        build                Generate diagrams and package the site so that it's ready to deploy on a static web server
        check-theme          See if there are any updates to the starter theme
        update-theme         Update the theme in our repo to the latest available
        check-makefile       Check to see if this Makefile differs from the starter repo's $(MASTER_MAKEFILE_URL)
        update-makefile      Update this Makefile to version in the starter repo $(MASTER_MAKEFILE_URL) and commit
        check-dependencies   See if Makefile and themes have been updated at their source locations
        update-dependencies  Update Makefile and theme dependencies from their source locations
        test                 Run the Hugo server in development mode
        clean                Remove all unversioned files
        clean-diagrams       Remove generated PlantUML diagrams
        check-graphviz-dot   See if Graphviz dot is installed
        generate-diagrams    Generate PlantUML diagrams anywhere in the content area and place them into a common images folder
        diagrams-usage       Displays list of files that are referencing diagrams
        clean-graphdoc       Remove generated GraphQL documentation files
        generate-graphql-schema-docs Generate GraphQL schema documents for all available GraphQL *.gql schema files
        generate-documents   Generate all static documents (e.g. GraphQL schema documents)
