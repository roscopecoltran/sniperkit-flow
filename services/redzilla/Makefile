# determine platform
ifeq (Darwin, $(findstring Darwin, $(shell uname -a)))
  PLATFORM 			:= MacOSX
  PLATFORM_SLUG 	:= macosx
  GO_BUILD_OS 		:= darwin
else
  PLATFORM 			:= Linux
  PLATFORM_SLUG 	:= linux
  GO_BUILD_OS 		:= $(PLATFORM_SLUG)
endif

# git
GIT_BRANCH			:= $(shell git rev-parse --abbrev-ref HEAD)
GIT_VERSION			:= $(shell git describe --always --long --dirty --tags)
GIT_REMOTE_URL		:= $(shell git config --get remote.origin.url)
GIT_TOP_LEVEL		:= $(shell git rev-parse --show-toplevel)

# app
APP_NAME 			:= redzille
APP_NAME_UCFIRST 	:= Redzilla
APP_BRANCH 			:= master
APP_DIST_DIR 		:= "$(CURDIR)/dist"

APP_PKG 			:= $(APP_NAME)
APP_PKGS 			:= $(shell go list ./... | grep -v /vendor/)
APP_VER				:= $(APP_VER)
APP_VER_FILE 		:= $(shell if [ -f ./VERSION ]; then cat ./VERSION ; fi)

# golang
GO_BUILD_LDFLAGS 	:= -a -ldflags="-X github.com/roscopecoltran/sniperkit-$(APP_NAME)/$(APP_PKG).$(APP_NAME_UCFIRST)Version=${APP_VER}"
GO_BUILD_PREFIX		:= $(APP_DIST_DIR)/all/$(APP_NAME)
GO_BUILD_URI		:= $(CURDIR)/src/cmd/...
GO_BUILD_VARS 		:= GOARCH=amd64 CGO_ENABLED=0

# golang - app
GO_BINDATA			:= $(shell which go-bindata)
GO_BINDATA_ASSETFS	:= $(shell which go-bindata-assetfs)
GO_GOX				:= $(shell which gox)
GO_GLIDE			:= $(shell which glide)
GO_VENDORCHECK		:= $(shell which vendorcheck)
GO_LINT				:= $(shell which golint)
GO_DEP				:= $(shell which dep)
GO_ERRCHECK			:= $(shell which errcheck)
GO_UNCONVERT		:= $(shell which unconvert)
GO_INTERFACER		:= $(shell which interfacer)

# general - helper
TR_EXEC				:= $(shell which tr)
AG_EXEC				:= $(shell which ag)
GIT_EXEC			:= $(shell which git)

# package managers
BREW_EXEC			:= $(shell which brew)
MACPORTS_EXEC		:= $(shell which ports)
APT_EXEC			:= $(shell which apt-get)
APK_EXEC			:= $(shell which apk)
YUM_EXEC			:= $(shell which yum)
DNF_EXEC			:= $(shell which dnf)

EMERGE_EXEC			:= $(shell which emerge)
PACMAN_EXEC			:= $(shell which pacmane)
SLACKWARE_EXEC		:= $(shell which sbopkg)
ZYPPER_EXEC			:= $(shell which zypper)
PKG_EXEC			:= $(shell which pkg)
PKG_ADD_EXEC		:= $(shell which pkg_add)

# APP_SRCS 			:= $(shell git ls-files '*.go' | grep -v '^vendor/')
# GIT_BRANCH 		:= $(subst heads/,,$(shell git rev-parse --abbrev-ref HEAD 2>/dev/null))

all: dist-local

default: all

test: ## launch unit tests for the current project
	@(go list ./... | grep -v "vendor/" | xargs -n1 go test -v -cover)

fmt: ## format the golang source code of the current project
	@(gofmt -w sift)

install: ## install locally the project binaries
	@cd $(CURDIR)/cmd/$(APP_NAME) && go install

dist: prepare dist-linux dist-darwin dist-windows ## cross-build the distribution version(s) of the app project

dist-local: dist-$(GO_BUILD_OS)	## build the project executable(s) for your local machine only.

dist-darwin: prepare ## build app executable for Apple platforms (aka darwin)
	@GOOS=darwin $(GO_BUILD_VARS) go build -a $(GO_BUILD_LDFLAGS) -o $(GO_BUILD_PREFIX)_darwin_amd64 -v $(GO_BUILD_URI)

dist-linux: prepare ## build app executable for Linux platforms
	@GOOS=linux $(GO_BUILD_VARS) go build -a $(GO_BUILD_LDFLAGS) -o $(GO_BUILD_PREFIX)_linux_amd64 -v $(GO_BUILD_URI)

dist-windows: prepare ## build app executable for windows platforms
	@GOOS=windows $(GO_BUILD_VARS) go build -a $(GO_BUILD_LDFLAGS) -o $(GO_BUILD_PREFIX)_windows_amd64.exe -v $(GO_BUILD_URI)

clean: glide-clean ## clean temporary files from previous build(s)
	go clean && rm -rf $(APP_DIST_DIR) && mkdir -p $(APP_DIST_DIR)

git: ## checkout/check the app active branch for building the project
	@clear
	@git submodule update --init
	@git checkout $(APP_BRANCH)
	@echo ""
	@echo "GIT_VERSION: $(GIT_VERSION)"
	@echo "GIT_BRANCH: $(GIT_BRANCH)"
	@echo "GIT_REMOTE_URL: $(GIT_REMOTE_URL)"
	@echo "GIT_TOP_LEVEL: $(GIT_TOP_LEVEL)"
	@echo ""

golang-fix-all: golang-fork-fix golang-logrus-fix

pkg-uri-clean:
	@rm -fR $(CURDIR)/vendor/github.com/roscopecoltran/sniperkit-sift
	@rm -fR $(CURDIR)/vendor/github.com/svent/sift

clear-screen:
	@clear
	@echo ""

pkg-uri-fix: install-ag pkg-uri-clean clear-screen ## fix sniperkit-sift pkg uri for golang package import
	@echo "fix sniperkit-sift pkg uri for golang package import"
	@$(AG_EXEC) -l 'github.com/svent/sift' --ignore Makefile --ignore *.md . | xargs sed -i -e 's/svent\/sift/roscopecoltran\/sniperkit-sift/g'
	@find . -name "*-e" -exec rm -f {} \; 

pkg-uri-revert: install-ag pkg-uri-clean clear-screen ## fix sift, fork, pkg uri for golang package import
	@echo "fix sift, fork, pkg uri for golang package import"
	@$(AG_EXEC) -l 'github.com/roscopecoltran/sniperkit-sift' --ignore Makefile --ignore *.md . | xargs sed -i -e 's/roscopecoltran\/sniperkit-sift/svent\/sift/g'
	@find . -name "*-e" -exec rm -f {} \;

golang-logrus-fix: install-ag clear-screen ## fix logrus case for golang package import
	@if [ -d $(CURDIR)/vendor/github.com/Sirupsen ]; then rm -fr vendor/github.com/Sirupsen ; fi
	@$(AG_EXEC) -l 'github.com/Sirupsen/logrus' vendor | xargs sed -i 's/Sirupsen/sirupsen/g'

go-github-fix:
	@if [ -d ./vendor/github.com/google/go-github/github ]; then find ./vendor/github.com/google/go-github/github -name activity_star.go -exec sed -i 's/mediaTypeStarringPreview/mediaTypeTopicsPreview/g' {} + ; fi

install-ag: install-ag-$(PLATFORM_SLUG) ## install the silver searcher (aka. ag)

# if [ "$choice" == 'y' ] && [ "$choice1" == 'y' ]; then
install-ag-macosx: clear-screen ## install the silver searcher on Apple/MacOSX platforms
	@echo "install the silver searcher on Apple/MacOSX platforms"
	@if [ -f $(BREW_EXEC) ] && [ ! -f $(AG_EXEC) ]; 		then $(BREW_EXEC) install the_silver_searcher; fi 
	@if [ -f $(MACPORTS_EXEC) ] && [ ! -f $(AG_EXEC) ]; 	then $(MACPORTS_EXEC) install the_silver_searcher ; fi	

install-ag-linux: clear-screen ## install the silver searcher on Linux platforms
	@echo "install the silver searcher on Linux platforms"
	@if [ -f $(APK_EXEC) ] && [ ! -f $(AG_EXEC) ]; 			then $(APK_EXEC) add --no-cache --update the_silver_searcher ; fi 
	@if [ -f $(APT_EXEC) ] && [ ! -f $(AG_EXEC) ]; 			then $(APT_EXEC) install -f --no-recommend silversearcher-ag ; fi 
	@if [ -f $(YUM_EXEC) ] && [ ! -f $(AG_EXEC) ]; 			then $(YUM_EXEC) install the_silver_searcher ; fi
	@if [ -f $(DNF_EXEC) ] && [ ! -f $(AG_EXEC) ]; 			then $(DNF_EXEC) install the_silver_searcher ; fi
	@if [ -f $(EMERGE_EXEC) ] && [ ! -f $(AG_EXEC) ]; 		then $(EMERGE_EXEC) -a sys-apps/the_silver_searcher ; fi
	@if [ -f $(PACMAN_EXEC) ] && [ ! -f $(AG_EXEC) ]; 		then $(PACMAN_EXEC) -S the_silver_searcher ; fi
	@if [ -f $(SLACKWARE_EXEC) ] && [ ! -f $(AG_EXEC) ]; 	then $(SLACKWARE_EXEC) -i the_silver_searcher ; fi
	@if [ -f $(ZYPPER_EXEC) ] && [ ! -f $(AG_EXEC) ]; 		then $(ZYPPER_EXEC) install the_silver_searcher ; fi
	@if [ -f $(PKG_EXEC) ] && [ ! -f $(AG_EXEC) ]; 			then $(PKG_EXEC) install the_silver_searcher ; fi
	@if [ -f $(PKG_ADD_EXEC) ] && [ ! -f $(AG_EXEC) ]; 		then $(PKG_ADD_EXEC) the_silver_searcher ; fi

push-tag:
	$(GIT_EXEC) checkout ${APP_BRANCH}
	$(GIT_EXEC) pull origin ${APP_BRANCH}
	$(GIT_EXEC) tag ${GIT_VERSION}
	$(GIT_EXEC) push origin ${APP_BRANCH} --tags

# print-%: ; @echo $*=$($*)

# print-%:
# 	@echo $* = $($*)

# .PHONY: printvars printvars-short
# printvars:
# 	@$(foreach V,$(sort $(.VARIABLES)), $(warning $V=$($V)))

# printvars-short:
# 	@$(foreach V,$(sort $(.VARIABLES)), \
# 	$(if $(filter-out environment% default automatic, \
# 	$(origin $V)),$(warning $V=$($V) ($(value $V)))))

# printvars-env:
#  	@$(foreach V,$(sort $(.VARIABLES)),$(if $(filter-out environment% default automatic,$(origin $V)),$(warning $V=$($V) ($(value $V)))))

#info/%:
#	@clear
#	@echo "PREFIX_BY: $(shell echo $* | tr '[:lower:]' '[:upper:]')_"
#	@$(foreach v, $(filter $(shell echo $* | tr '[:lower:]' '[:upper:]')_%,$(.VARIABLES)), $(echo $(v) = $($(v))))
#		# $(foreach v, $(filter $(PREFIX_BY)%,$(.VARIABLES)), $(info $(v) = $($(v))))

app-info:
	@clear
	@echo ""
	@echo "APP_NAME: $(APP_NAME)"
	@echo "APP_BRANCH: $(APP_BRANCH)"
	@echo "APP_DIST_DIR: $(APP_DIST_DIR)"
	@echo "APP_VER: $(APP_VER)"
	@echo "APP_VER_FILE: $(APP_VER_FILE)"
	@echo ""

git-status: ## checkout/check the app active branch for building the project
	@git status

gox: golang-install-deps gox-xbuild ## install missing dependencies and cross-compile app for macosx, linux and windows platforms

gox-darwin: ## generate all binaries for Mac/Apple platforms for the project with gox utility
	@gox -verbose -os="darwin" -arch="amd64" -output="{{.Dir}}_{{.OS}}_{{.Arch}}" $(APP_PKGS) # $(glide novendor)

gox-dist: ## generate all binaries for the project with gox utility
	@gox -verbose -os="darwin linux windows" -arch="amd64" -output="$(APP_DIST_DIR)/{{.OS}}/{{.Dir}}_{{.Os}}_{{.Arch}}" $(APP_PKGS) # $(glide novendor)

glide: glide-create glide-install ## install and manage all project dependencies via glide utility

glide-clean: ## clean glide utility cache (hint: check the contant of dirs available at \$GLIDE_TMP and \$GLIDE_HOME)
	@glide cc

glide-create: ## create the list of used dependencies in this golang project, via glide utility
	@if [ ! -f $(CURDIR)/glide.yaml ]; then glide create --non-interactive ; fi

glide-install: ## install app/pkg dependencies via glide utility
	@if [ -f $(CURDIR)/glide.yaml ]; then glide install --strip-vendor ; fi

golang-install-deps: golang-package-deps golang-embedding-deps golang-test-deps ## install global golang pkgs/deps

golang-package-deps: 
	@if [ ! -f $(GO_GOX) ]; then go get -v github.com/mitchellh/gox ; fi
	@if [ ! -f $(GO_GLIDE) ]; then go get -v github.com/Masterminds/glide ; fi

golang-embedding-deps: 
	@if [ ! -f $(GO_BINDATA) ]; then go get -v github.com/jteeuwen/go-bindata/... ; fi
	@if [ ! -f $(GO_BINDATA_ASSETFS) ]; then go get -v github.com/elazarl/go-bindata-assetfs/... ; fi

golang-test-deps: ## install unit-tests/debugging dependencies
	@if [ ! -f $(GO_VENDORCHECK) ]; then go get -u github.com/FiloSottile/vendorcheck ; fi
	@if [ ! -f $(GO_LINT) ]; then go get -u github.com/golang/lint/golint ; fi
	@if [ ! -f $(GO_DEP) ]; then go get -u github.com/golang/dep/cmd/dep ; fi
	@if [ ! -f $(GO_ERRCHECK) ]; then go get -u github.com/kisielk/errcheck ; fi
	@if [ ! -f $(GO_UNCONVERT) ]; then go get -u github.com/mdempsky/unconvert ; fi
	@if [ ! -f $(GO_INTERFACER) ]; then go get -u github.com/mvdan/interfacer/cmd/interfacer ; fi
	go get -u github.com/opennota/check/...
	go get -u github.com/yosssi/goat/...
	go get -u honnef.co/go/tools/...

# build-linux:
# 	CGO_ENABLED=0 go build -a -ldflags '-s' -o ./dist/redzilla_darwin_amd64

# build-darwin:
# 	CGO_ENABLED=0 go build -a -ldflags '-s' -o ./dist/redzilla_darwin_amd64

# golang-go-github-fix:
# 	@if [ -d $(CURDIR)/vendor/github.com/google/go-github/github ]; then find . -type f -name "*.go" -exec sed -i 's/Starred/Topics/g' {} + ; fi

prepare: git golang-install-deps ## prepare required destination folders
	@mkdir -p $(APP_DIST_DIR) $(APP_DIST_DIR)/darwin $(APP_DIST_DIR)/linux $(APP_DIST_DIR)/windows

travis: install-deps golang-install-deps golang-logrus-fix ## travis-ci builc
	@echo "building..."
	@go build

help: ## show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# benchmark:
# 	go test -bench=. -benchtime=3s $(APP_PKGS)

#coveralls: all
#	go get github.com/mattn/goveralls
#	sh coverage.sh --coveralls

