# 
# TODO -- check out https://gist.github.com/bowmanjd/d1687aa3ed921608c343 for automating Sass builds, Javascript bundling, minification, etc. 
# TODO -- make .plantuml generation smarter by only generating if source file is newer (right now we brute-force generate all of them)

MAKEF_PATH = $(shell pwd)
DEPLOY_PATH = "public"
DIAGRAMS_SRC_PATH = "$(MAKEF_PATH)/content"
DIAGRAMS_DEST_PATH = "$(MAKEF_PATH)/static/img/generated/diagrams"
PLANTUML_JAR_URL = "https://sourceforge.net/projects/plantuml/files/plantuml.jar/download"
PLANTUML_JAR = plantuml.jar
THEME_NAME = netspective
THEME_PATH = themes/$(THEME_NAME)

MAKEFLAGS := --silent

all: test

build: generate-diagrams
	hugo

check-theme:
	cd $(THEME_PATH) && \
	git fetch && \
	git log --pretty=oneline

update-theme:
	cd $(THEME_PATH) && \
	git submodule update --remote --merge

test:
	hugo server --bind=127.0.0.1 --baseUrl="localhost" --buildDrafts

clean: clean-diagrams
	rm -rf $(PLANTUML_JAR)
	rm -rf $(DEPLOY_PATH)

$(PLANTUML_JAR):
	@# --content-disposition tells wget to get $(PLANTUML_JAR_URL) and download it to $(PLANTUML_JAR)
	wget -q --content-disposition -N $(PLANTUML_JAR_URL)

clean-diagrams:
	rm -rf $(DIAGRAMS_DEST_PATH)

generate-diagrams: $(PLANTUML_JAR) clean-diagrams
	mkdir -p $(DIAGRAMS_DEST_PATH)
	echo "This directory is generated and may be deleted before re-generating files." > $(DIAGRAMS_DEST_PATH)/README.md
	echo "Generating PlantUML diagrams from $(DIAGRAMS_SRC_PATH)/*.plantuml recursively"
	java -jar $(PLANTUML_JAR) -recurse -v -o $(DIAGRAMS_DEST_PATH) "$(DIAGRAMS_SRC_PATH)/*.plantuml"
	git status $(DIAGRAMS_DEST_PATH)

.PHONY: $(PLANTUML_JAR)
