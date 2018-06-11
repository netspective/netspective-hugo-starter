# 
# TODO -- add targets to deploy on web server (NGINX, etc.)
# TODO -- check out https://gist.github.com/bowmanjd/d1687aa3ed921608c343 for automating Sass builds, Javascript bundling, minification, etc. 
# TODO -- make .plantuml generation smarter by only generating if source file is newer (right now we brute-force generate all of them), similar to https://gist.github.com/hjst/4f2f2c2ca9bd550e50c7f06cb17775b2

MAKEF_PATH = $(shell pwd)
BUILD_PATH = public
DIAGRAMS_SRC_REL_PATH = content
DIAGRAMS_SRC_PATH = $(MAKEF_PATH)/$(DIAGRAMS_SRC_REL_PATH)
DIAGRAMS_DEST_REL_PATH = static/img/generated/diagrams
DIAGRAMS_DEST_PATH = $(MAKEF_PATH)/$(DIAGRAMS_DEST_REL_PATH)
DIAGRAMS_DEST_SEARCH_REF = img/generated/diagrams
DOCUMENTS_DEST_REL_PATH = static/docs/generated
DOCUMENTS_DEST_PATH = $(MAKEF_PATH)/$(DOCUMENTS_DEST_REL_PATH)
GRAPHDOC_SRC_PATH = content
GRAPHDOC_DEST_REL_PATH = $(DOCUMENTS_DEST_REL_PATH)/graphdoc
GRAPHDOC_DEST_PATH = $(MAKEF_PATH)/$(GRAPHDOC_DEST_REL_PATH)
MASTER_MAKEFILE_URL = https://raw.githubusercontent.com/netspective/netspective-hugo-starter/master/Makefile
PLANTUML_JAR_URL = https://sourceforge.net/projects/plantuml/files/plantuml.jar/download
PLANTUML_JAR = plantuml.jar
PLANTUML_EXT = .plantuml
THEME_NAME = netspective
THEME_PATH = themes/$(THEME_NAME)

TREE_INSTALLED := $(shell command -v tree 2> /dev/null)
ifndef TREE_INSTALLED
	$(error "tree command not available, please install it")
endif

GRAPHVIZ_DOT_INSTALLED := $(shell command -v dot 2> /dev/null)
NPM_INSTALLED := $(shell command -v npm 2> /dev/null)
GRAPHDOC_INSTALLED := $(shell command -v graphdoc 2> /dev/null)

ifneq ($(shell find $(DIAGRAMS_SRC_PATH) -name "*$(PLANTUML_EXT)" -exec echo {} \;),"")
HAVE_DIAGRAMS = TRUE
else
HAVE_DIAGRAMS = FALSE
endif

SHELL := /bin/bash
MAKEFLAGS := --silent
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)
ifeq (Windows_NT,$(OS))
OS_NAME := Windows
OS_CPU  := $(call _lower,$(PROCESSOR_ARCHITECTURE))
OS_ARCH := $(if $(findstring amd64,$(OS_CPU)),x86_64,i686)
else
OS_NAME := $(shell uname -s)
OS_ARCH := $(shell uname -m)
OS_CPU  := $(if $(findstring 64,$(OS_ARCH)),amd64,x86)
endif

## Default is to run this in development mode for testing the website
default: test

## Generate diagrams and package the site so that it's ready to deploy on a static web server
build: generate-all
	hugo

.ONESHELL:
## See if there are any updates to the starter theme
check-theme:
	cd $(THEME_PATH)
	printf "${WHITE}"
	git config --get remote.origin.url 
	printf "${YELLOW}"
	git fetch
	printf "${GREEN}"
	git status
	printf "${RESET}"

.ONESHELL:
## Update the theme in our repo to the latest available
update-theme:
	cd $(THEME_PATH)
	printf "${WHITE}"
	git config --get remote.origin.url 
	printf "${YELLOW}"
	git checkout master
	printf "${GREEN}"
	git pull
	printf "${RESET}"

## Check to see if this Makefile differs from the starter repo's $(MASTER_MAKEFILE_URL)
check-makefile:
	diff --side-by-side --suppress-common-lines Makefile <(curl -s $(MASTER_MAKEFILE_URL)) || echo "${YELLOW}Makefile is different${RESET}, run '${GREEN}make update-makefile${RESET}' to get the latest version."

.ONESHELL:
## Update this Makefile to version in the starter repo $(MASTER_MAKEFILE_URL) and commit
update-makefile:
	curl -sSfL $(MASTER_MAKEFILE_URL) -o Makefile
	git commit Makefile -m "Updated to match latest at $(MASTER_MAKEFILE_URL)"

## See if Makefile and themes have been updated at their source locations
check-dependencies: check-makefile check-theme 

## Update Makefile and theme dependencies from their source locations
update-dependencies: update-makefile update-theme

## Run the Hugo server in development mode
test:
	hugo server --bind=127.0.0.1 --baseUrl="localhost" --buildDrafts

## Remove all unversioned files
clean: clean-diagrams clean-graphdoc
	printf "Cleaned ${GREEN}$(PLANTUML_JAR)${RESET}, entries removed: " && rm -rfv $(PLANTUML_JAR) | wc -l
	printf "Cleaned ${GREEN}$(BUILD_PATH)${RESET}, entries removed: " && rm -rfv $(BUILD_PATH) | wc -l
	printf "Pruned empty directories, entries removed: " && find . -type d -empty -exec echo {} \; | wc -l
	find . -type d -empty -delete

## Download the latest version of the plantuml.jar file from source location
$(PLANTUML_JAR):
	@# --content-disposition tells wget to get $(PLANTUML_JAR_URL) and download it to $(PLANTUML_JAR)
	wget -q --content-disposition -N $(PLANTUML_JAR_URL)

## Remove generated PlantUML diagrams
clean-diagrams:
	printf "Cleaned ${GREEN}$(DIAGRAMS_DEST_REL_PATH)${RESET}, entries removed: " && rm -rfv $(DIAGRAMS_DEST_PATH) | wc -l

## See if Graphviz dot is installed
check-graphviz-dot:
ifndef GRAPHVIZ_DOT_INSTALLED
	echo "dot command is not available, please install graphviz."
endif

ifeq ("$(HAVE_DIAGRAMS)", "TRUE")
.ONESHELL:
## Generate PlantUML diagrams anywhere in the content area and place them into a common images folder
generate-diagrams: check-graphviz-dot $(PLANTUML_JAR) clean-diagrams
	mkdir -p $(DIAGRAMS_DEST_PATH)
	printf "PlantUML Diagrams\n" > $(DIAGRAMS_DEST_PATH)/README.md
	printf "=================\n" >> $(DIAGRAMS_DEST_PATH)/README.md
	printf "_This directory was generated on **`date`** and may be deleted before re-generating files_.\n\n" >> $(DIAGRAMS_DEST_PATH)/README.md
	printf "Generated PlantUML diagrams from $(DIAGRAMS_SRC_REL_PATH)/*$(PLANTUML_EXT) recursively.\n" >> $(DIAGRAMS_DEST_PATH)/README.md
	java -jar $(PLANTUML_JAR) -recurse -v -o $(DIAGRAMS_DEST_PATH) "$(DIAGRAMS_SRC_PATH)/**/*$(PLANTUML_EXT)" 2>> $(DIAGRAMS_DEST_PATH)/README.md
	printf "Diagrams generated: ${YELLOW}"
	cat $(DIAGRAMS_DEST_PATH)/README.md | awk '/Creating file:/ { ++count } END { print count }' 
	printf "${RESET}Log: ${GREEN}$(DIAGRAMS_DEST_REL_PATH)/README.md${RESET}\n"
	git status $(DIAGRAMS_DEST_PATH)

.ONESHELL:
## Displays list of files that are referencing diagrams
diagrams-usage:
	printf "Diagram Sources:${YELLOW}\n"
	find $(DIAGRAMS_SRC_REL_PATH) -name "*$(PLANTUML_EXT)" -exec echo {} \;
	printf "${RESET}\n"
	printf "Diagram Shortcode Usage:${YELLOW}\n"
	find $(DIAGRAMS_SRC_REL_PATH) -name "*.md" -exec grep -nHo -e '{{.*plantuml.*}}' {} \;
	printf "${RESET}\n"
	printf "Diagram Destination Usage (should be empty, use shortcode):${YELLOW}\n"
	find $(DIAGRAMS_SRC_REL_PATH) -name "*.md" -exec grep -nHo -e '$(DIAGRAMS_DEST_SEARCH_REF).*.*\..*' {} \;	
	printf "${RESET}"
else
generate-diagrams: clean-diagrams
	echo "No ${GREEN}*$(PLANTUML_EXT)${RESET} diagrams exist in ${GREEN}$(DIAGRAMS_SRC_REL_PATH)${RESET}, ignoring ${YELLOW}$@${RESET} target."

diagrams-usage:
	echo "No ${GREEN}*$(PLANTUML_EXT)${RESET} diagrams exist in ${GREEN}$(DIAGRAMS_SRC_REL_PATH)${RESET}, ignoring ${YELLOW}$@${RESET} target."
endif

check-npm:
ifndef NPM_INSTALLED
	echo "Node package manager npm is not available, please install NodeJS."
endif

check-graphdoc: check-npm
ifndef GRAPHDOC_INSTALLED
	echo "GraphQL documentation generator not available, install: ${GREEN}npm install -g @2fd/graphdoc${RESET}"
endif

## Remove generated GraphQL documentation files
clean-graphdoc:
	printf "Cleaned ${GREEN}$(GRAPHDOC_DEST_REL_PATH)${RESET}, entries removed: " && rm -rfv $(GRAPHDOC_DEST_PATH) | wc -l

.ONESHELL:
## Generate GraphQL schema documents for all available GraphQL *.gql schema files
generate-graphql-schema-docs: check-graphdoc clean-graphdoc
	mkdir -p $(GRAPHDOC_DEST_PATH)
	find $(GRAPHDOC_SRC_PATH) -name "*.gql" -exec graphdoc -s {} -o $(GRAPHDOC_DEST_PATH)/{} --force &>> $(GRAPHDOC_DEST_PATH)/graphdoc.log \;
	echo "Check ${GREEN}$(GRAPHDOC_DEST_PATH)/graphdoc.log${RESET}."
	tree -d $(GRAPHDOC_DEST_PATH)

## Generate all static documents (e.g. GraphQL schema documents)
generate-documents: generate-graphql-schema-docs

## Generate all diagrams, documents, etc. for the entire project
generate-all: generate-diagrams generate-documents

TARGET_MAX_CHAR_NUM=20
## All targets should have a ## Help text above the target and they'll be automatically collected
## Show help, using auto generator from https://gist.github.com/prwhite/8168133
help:
	@echo ''
	@echo 'Usage:'
	@echo '  ${YELLOW}make${RESET} ${GREEN}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf "  ${YELLOW}%-$(TARGET_MAX_CHAR_NUM)s${RESET} ${GREEN}%s${RESET}\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@echo ''
	@echo 'Directives:'
	@echo "  ${YELLOW}HAVE_DIAGRAMS${RESET}            '${GREEN}$(HAVE_DIAGRAMS)${RESET}'"
	@echo "  ${YELLOW}DIAGRAMS_SRC_REL_PATH${RESET}    '${GREEN}$(DIAGRAMS_SRC_REL_PATH)${RESET}'"
	@echo "  ${YELLOW}DIAGRAMS_SRC_PATH${RESET}        '${GREEN}$(DIAGRAMS_SRC_PATH)${RESET}'"
	@echo "  ${YELLOW}DIAGRAMS_DEST_REL_PATH${RESET}   '${GREEN}$(DIAGRAMS_DEST_REL_PATH)${RESET}'"
	@echo "  ${YELLOW}DIAGRAMS_DEST_PATH${RESET}       '${GREEN}$(DIAGRAMS_DEST_PATH)${RESET}'"
	@echo "  ${YELLOW}DIAGRAMS_DEST_SEARCH_REF${RESET} '${GREEN}$(DIAGRAMS_DEST_SEARCH_REF)${RESET}'"
	@echo ''
	@echo "  ${YELLOW}DOCUMENTS_DEST_REL_PATH${RESET} '${GREEN}$(DOCUMENTS_DEST_REL_PATH)${RESET}'"
	@echo "  ${YELLOW}DOCUMENTS_DEST_PATH${RESET}     '${GREEN}$(DOCUMENTS_DEST_PATH)${RESET}'"
	@echo "  ${YELLOW}GRAPHDOC_SRC_PATH${RESET}       '${GREEN}$(GRAPHDOC_SRC_PATH)${RESET}'"
	@echo "  ${YELLOW}GRAPHDOC_DEST_REL_PATH${RESET}  '${GREEN}$(GRAPHDOC_DEST_REL_PATH)${RESET}'"
	@echo "  ${YELLOW}GRAPHDOC_DEST_PATH${RESET}      '${GREEN}$(GRAPHDOC_DEST_PATH)${RESET}'"
	@echo ''
	@echo "  ${YELLOW}MASTER_MAKEFILE_URL${RESET} '${GREEN}$(MASTER_MAKEFILE_URL)${RESET}'"
	@echo "  ${YELLOW}PLANTUML_JAR_URL${RESET}    '${GREEN}$(PLANTUML_JAR_URL)${RESET}'"
	@echo ''
	@echo "  ${YELLOW}OS_NAME${RESET} '${GREEN}$(OS_NAME)${RESET}'"
	@echo "  ${YELLOW}OS_CPU${RESET}  '${GREEN}$(OS_CPU)${RESET}'"
	@echo "  ${YELLOW}OS_ARCH${RESET} '${GREEN}$(OS_ARCH)${RESET}'"

.PHONY: $(PLANTUML_JAR) help
