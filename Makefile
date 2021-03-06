# Go super project Makefile
# Authored by Mikael Silvén

# You want to edit these
REPOSITORY	:= github.com/dretay/labrack-go
PACKAGES 	:= common

# Maybe even these
CMD_DIR		:= cmd
PROTO_DIR := proto
GOFMT		:= @gofmt -s -w -l
COV_EXT     := cov
TEST_COV	:= @go test -cover -coverprofile=
CLI_COV		:= go tool cover -func=
WEB_COV 	:= go tool cover -html=
GOTEST		:= @go test
GORUN		:= go run
GOVET		:= @go vet
OPEN_CMD	:= xdg-open
ZIP_FILE	:= godoc.zip
BIN_DIR		:= bin
PROTOC := protoc

# But dont edit these
GOOS		:= $(shell go env GOOS)
GOARCH		:= arm#$(shell go env GOARCH)
GOBUILD		:= GOOS=$(GOOS) GOARCH=$(GOARCH) go build
GOINSTALL	:= GOOS=$(GOOS) GOARCH=$(GOARCH) go install -v
RUNNABLES	:= $(wildcard $(CMD_DIR)/*.go)
PKG_ROOT	:= $(GOPATH)/pkg/$(GOOS)_$(GOARCH)/$(REPOSITORY)
A_FILES		:= $(foreach pkg, $(PACKAGES), $(PKG_ROOT)/$(pkg).a)
TESTABLE	:= $(foreach pkg, $(PACKAGES), $(wildcard $(pkg)/*.go))
GOFILES		:= $(TESTABLE) $(RUNNABLE)
COV_FILES	:= $(foreach pkg, $(PACKAGES), $(pkg).$(COV_EXT))
PROTO_FILES := $(wildcard $(PROTO_DIR)/*.proto)
COMPILED_PROTO_FILES := $(wildcard $(PROTO_DIR)/*.go)
COMPILED_BINARIES := $(wildcard $(BIN_DIR)/*)

default:	fmt vet protoc test install build run

$(notdir $(basename $(RUNNABLES))): .fmt .vet .test install
		@GOOS=$(GOOS) GOARCH=$(GOARCH) $(GORUN) $(CMD_DIR)/$@.go
run:
	$(foreach binary,$(COMPILED_BINARIES), scp $(binary) drew@192.168.1.24:~/;)
	ssh drew@192.168.1.24  './i2c'


protoc:
		git submodule update --remote --merge
		$(foreach proto,$(PROTO_FILES), $(PROTOC) --go_out=. $(proto))
bench:	$(TESTABLE)
		$(GOTEST) -bench . $(foreach lib, $(sort $(^D)), $(REPOSITORY)/$(lib))

build:	$(foreach bin, $(notdir $(basename $(RUNNABLES))), $(BIN_DIR)/$(bin))

$(BIN_DIR)/%: $(CMD_DIR)/%.go $(TESTABLE)
		test -d $(BIN_DIR) || mkdir -p $(BIN_DIR)
		$(GOBUILD) -o $(BIN_DIR)/$* $<

test:	$(TESTABLE)
		$(GOTEST) $(foreach lib, $(sort $(^D)), $(REPOSITORY)/$(lib))

.test:	$(TESTABLE)
		$(GOTEST) $(foreach lib, $(sort $(?D)), $(REPOSITORY)/$(lib))
		@touch .test

fmt:	$(GOFILES)
		$(GOFMT) $^

.fmt:	$(GOFILES)
		$(GOFMT) $?
		@touch .fmt

vet:	$(TESTABLE)
		$(GOVET) $(addprefix $(REPOSITORY)/, $(sort $(^D)))

.vet:	$(TESTABLE)
		$(GOVET) $(addprefix $(REPOSITORY)/, $(sort $(?D)))
		@touch .vet

$(COV_FILES): $(TESTABLE)
		$(TEST_COV)$@ $(REPOSITORY)/$(basename $@)

cov: 	$(COV_FILES)
		@$(foreach file, $^, $(CLI_COV)$(file);)

cov-html: $(COV_FILES)
		@$(foreach file, $^, $(WEB_COV)$(file);)

$(ZIP_FILE): $(TESTABLE)
		@test -e $@ && zip -u -r $@ $? || zip -r $@ $(TESTABLE) $(GOROOT)lib/godoc/

godoc:	$(ZIP_FILE)
		$(OPEN_CMD) http://localhost:6060/pkg/$(REPOSITORY)
		godoc -http=:6060 -zip=$(ZIP_FILE)

clean:
		$(RM) *.$(COV_EXT)
		$(RM) $(ZIP_FILE)
		$(RM) -r $(BIN_DIR)
		$(RM) .fmt
		$(RM) .test
		$(RM) .vet
		$(RM) .vet
		$(foreach proto,$(COMPILED_PROTO_FILES), $(RM) $(proto))

install: $(A_FILES)
$(PKG_ROOT)/%.a:	%/*.go
		@cd $* && $(GOINSTALL)

.PHONY: default test vet fmt install godoc clean cov cov-html build bench

