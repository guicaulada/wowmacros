PYTHON ?= python3
LUA ?= luajit

.PHONY: generate check check-generated test test-tooling install-hooks

generate:
	$(PYTHON) scripts/build.py

check: check-generated test

check-generated:
	$(PYTHON) scripts/build.py --check

test:
	$(LUA) tests/validate.lua
	$(LUA) tests/importer.lua

test-tooling:
	$(PYTHON) -m unittest discover -s tests -p 'test_*.py' -v

install-hooks:
	git config --local core.hooksPath .githooks
