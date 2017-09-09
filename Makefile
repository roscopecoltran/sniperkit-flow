PACKAGES = $(shell go list ./... | grep -v /vendor/)

# determine platform
ifeq (Darwin, $(findstring Darwin, $(shell uname -a)))
  PLATFORM 			:= macosx
  GO_BUILD_OS 		:= darwin
else
  PLATFORM 			:= Linux
  GO_BUILD_OS 		:= linux
endif

# git
GIT_BRANCH			:= $(shell git rev-parse --abbrev-ref HEAD)
GIT_VERSION			:= $(shell git describe --always --long --dirty --tags)
GIT_REMOTE_URL		:= $(shell git config --get remote.origin.url)
GIT_TOP_LEVEL		:= $(shell git rev-parse --show-toplevel)

# app
APP_NAME 			:= goflow
APP_NAME_UCFIRST 	:= GoFlow
APP_BRANCH 			:= pkg
APP_DIST_DIR 		:= "$(CURDIR)/dist"

APP_PKG 			:= $(APP_NAME)
APP_PKGS 			:= $(shell go list ./... | grep -v /vendor/)
APP_VER				:= $(APP_VER)
APP_VER_FILE 		:= $(shell git describe --always --long --dirty --tags)

# golang
GO_BUILD_LDFLAGS 	:= -a -ldflags="-X github.com/roscopecoltran/$(APP_NAME)/$(APP_PKG).$(APP_NAME_UCFIRST)Version=${APP_VER}"
GO_BUILD_PREFIX		:= $(APP_DIST_DIR)/all/$(APP_NAME)
GO_BUILD_URI		:= github.com/roscopecoltran/$(APP_NAME)/cmd/$(APP_NAME)
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

default: build

install: build
	go install

build: check
	go build

dist: macos linux windows

darwin:
	clear
	echo ""
	rm -f ./limo
	gox -verbose -os="darwin" -arch="amd64" -output="{{.Dir}}" ./cmd/...
	echo ""

# darwin:
# 	gox -verbose -os="darwin" -arch="amd64" -output="{{.Dir}}" ./cmd/$*/...

git-status: ## checkout/check the app active branch for building the project
	@git status

gox: golang-install-deps gox-xbuild ## install missing dependencies and cross-compile app for macosx, linux and windows platforms

gox-dist: ## generate all binaries for the project with gox utility
	@gox -verbose -os="darwin linux windows" -arch="amd64" -output="$(APP_DIST_DIR)/{{.Os}}/{{.Dir}}_{{.Os}}_{{.Arch}}" $(APP_PKGS) # $(glide novendor)

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

golang-fix-all: golang-fork-fix golang-logrus-fix

pkg-uri-clean:
	@rm -fR $(CURDIR)/vendor/github.com/roscopecoltran/sniperkit-limo
	@rm -fR $(CURDIR)/vendor/github.com/hoop33/limo

clear-screen:
	@clear
	@echo ""

pkg-uri-fix: install-ag pkg-uri-clean clear-screen ## fix sniperkit-limo pkg uri for golang package import
	@echo "fix sniperkit-limo pkg uri for golang package import"
	@$(AG_EXEC) -l 'github.com/hoop33/limo' --ignore Makefile --ignore *.md . | xargs sed -i -e 's/hoop33\/limo/roscopecoltran\/sniperkit-limo/g'
	@find . -name "*-e" -exec rm -f {} \; 

pkg-uri-revert: install-ag pkg-uri-clean clear-screen ## fix limo, fork, pkg uri for golang package import
	@echo "fix limo, fork, pkg uri for golang package import"
	@$(AG_EXEC) -l 'github.com/roscopecoltran/sniperkit-limo' --ignore Makefile --ignore *.md . | xargs sed -i -e 's/roscopecoltran\/sniperkit-limo/hoop33\/limo/g'
	@find . -name "*-e" -exec rm -f {} \; 

golang-logrus-fix: install-ag clear-screen ## fix logrus case for golang package import
	@if [ -d $(CURDIR)/vendor/github.com/Sirupsen ]; then rm -fr vendor/github.com/Sirupsen ; fi
	@$(AG_EXEC) -l 'github.com/Sirupsen/logrus' vendor | xargs sed -i 's/Sirupsen/sirupsen/g'

go-github-fix:
	@if [ -d ./vendor/github.com/google/go-github/github ]; then find ./vendor/github.com/google/go-github/github -name activity_star.go -exec sed -i 's/mediaTypeStarringPreview/mediaTypeTopicsPreview/g' {} + ; fi

install-ag: install-ag-$(PLATFORM) ## install the silver searcher (aka. ag)

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

macos:
	GOOS=darwin go build -o $(APP_DIST_DIR)/macos/$(APP_NAME)

linux:
	GOOS=linux go build -o $(APP_DIST_DIR)/linux/$(APP_NAME)

windows:
	GOOS=windows go build -o $(APP_DIST_DIR)/windows/$(APP_NAME).exe

check: vet lint errcheck interfacer aligncheck structcheck varcheck unconvert gosimple staticcheck unused vendorcheck test

vet:
	go vet $(PACKAGES)

lint:
	golint -set_exit_status $(PACKAGES)

errcheck:
	errcheck $(PACKAGES)

interfacer:
	interfacer $(PACKAGES)

aligncheck:
	aligncheck $(PACKAGES)

structcheck:
	structcheck $(PACKAGES)

varcheck:
	varcheck $(PACKAGES)

unconvert:
	unconvert -v $(PACKAGES)

gosimple:
	gosimple $(PACKAGES)

staticcheck:
	staticcheck $(PACKAGES)

unused:
	unused $(PACKAGES)

vendorcheck:
	vendorcheck $(PACKAGES)
	vendorcheck -u $(PACKAGES)

test:
	go test -cover $(PACKAGES)

coverage:
	echo "mode: count" > coverage-all.out
	$(foreach pkg,$(PACKAGES),\
		go test -coverprofile=coverage.out -covermode=count $(pkg);\
		tail -n +2 coverage.out >> coverage-all.out;)
	go tool cover -html=coverage-all.out

clean:
	@go clean && rm -rf dist/*
	@find . -name "*-e" -exec rm -f {} \; 

deps:
	go get -u github.com/FiloSottile/vendorcheck
	go get -u github.com/golang/lint/golint
	go get -u github.com/golang/dep/cmd/dep
	go get -u github.com/kisielk/errcheck
	go get -u github.com/mdempsky/unconvert
	go get -u github.com/mvdan/interfacer/cmd/interfacer
	go get -u github.com/opennota/check/...
	go get -u github.com/yosssi/goat/...
	go get -u honnef.co/go/tools/...
