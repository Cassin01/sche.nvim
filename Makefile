all: lua/sche/init.lua

lua/%.lua: fnl/%.fnl
	fennel --compile $< > $@
