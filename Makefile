PACKAGES = granola granola-schema

### From here on now, it should be the same for all libraries :)

ifndef GS_NAME
  $(error GS_NAME not set. Have you `gs in` yet?)
endif

DEPS := ${GEM_HOME}/installed
PACKAGES ?= $(shell basename `pwd`)
VERSION := $(shell grep VERSION lib/*/version.rb | sed -e 's/VERSION =//' -e 's/[ "]//g')
GEMS := $(addprefix pkg/, $(addsuffix -$(VERSION).gem, $(PACKAGES)))

export RUBYOPT=-Ilib
export RUBYLIB=$RUBYLIB:test

all: test $(GEMS)

test: $(DEPS)
	cutest -r ./test/helper.rb ./test/**/*_test.rb

clean:
	rm pkg/*.gem

release: $(GEMS)
	for gem in $^; do gem push $$gem; done

pkg/%-$(VERSION).gem: %.gemspec lib/*/version.rb
	gem build $<
	mv $(@F) pkg/

$(DEPS): $(GEM_HOME) .gems
	which dep &>/dev/null || gem install dep
	dep install
	touch .gs/installed

.PHONY: all test release clean
