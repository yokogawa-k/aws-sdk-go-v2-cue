# vi: set ft=make ts=2 sw=2 sts=0 noet:

SHELL := /bin/bash
REPOSITORY := github.com/aws/aws-sdk-go-v2
SERVICES := ec2 ecs eks


.PHONY: default
default: help

# http://postd.cc/auto-documented-makefile/
.PHONY: help help-common
help: help-common

help-common:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m %-30s\033[0m %s\n", $$1, $$2}'

.PHONY: init goget generate
init:
	go mod init
	cue mod init

.PHONY: all
all: $(SERVICES)

define services-template
.PHONY: goget-$(1) generate-$(1) sync-$(1) $(1)
goget-$(1):
	go get $(REPOSITORY)/service/$(1)/types

generate-$(1): goget-$(1)
	cue get go $(REPOSITORY)/service/$(1)/types

sync-$(1): generate-$(1)
	rsync -avKi cue.mod/gen/$(REPOSITORY)/service/$(1)/types/ ./service/$(1)

$(1): sync-$(1)

endef

$(foreach _srv,$(SERVICES),$(eval $(call services-template,$(_srv))))