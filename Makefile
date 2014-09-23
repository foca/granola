.PHONY: test gems

test:
	cutest -r ./test/helper.rb ./test/**/*_test.rb

gems:
	dep install
