.PHONY: test deps gems release

test:
	cutest -r ./test/helper.rb ./test/**/*_test.rb

deps:
	dep install

gems:
	for gem in granola*.gemspec; do gem build $$gem; done
	mv *.gem pkg/

release:
	for gem in pkg/*.gem; do gem push $$gem; done
