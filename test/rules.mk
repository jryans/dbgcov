THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
DBGCOV_PREFIX ?= $(realpath $(dir $(THIS_MAKEFILE))/..)

-include $(DBGCOV_PREFIX)/config.mk
export TOOLSUB

# HACK: for now, force C++11 and C99
BASIC_CXXFLAGS += -std=c++11 -save-temps
BASIC_CFLAGS += -std=c99 -save-temps

# We build all our tests by running them through our dbgcov wrapper.
CXXFLAGS += `$(DBGCOV_PREFIX)/bin/dbgcov-cxxflags` $(BASIC_CXXFLAGS)
CFLAGS += `$(DBGCOV_PREFIX)/bin/dbgcov-cflags` $(BASIC_CFLAGS)

%.vanilla.ii: %.cpp
	$(CXX) $(BASIC_CXXFLAGS) -E -o $@ $<
%.vanilla.ii: %.cc
	$(CXX) $(BASIC_CXXFLAGS) -E -o $@ $<
%.ii: %.cpp
	$(CXX) $(CXXFLAGS) -E -o $@ $<
%.ii: %.cc
	$(CXX) $(CXXFLAGS) -E -o $@ $<
%.ast: %.vanilla.ii
	$(DBGCOV_PREFIX)/src/dump $< 2>$@ || (rm -f $@; false)

%.vanilla.i: %.c
	$(CC) $(BASIC_CFLAGS) -E -o $@ $<
%.i: %.c
	$(CC) $(CFLAGS) -E -o $@ $<
%.ast: %.vanilla.i
	$(DBGCOV_PREFIX)/src/dump $< 2>$@ || (rm -f $@; false)

%.o: %.ii
	$(CXX) $(CXXFLAGS) -c -o $@ $<
%.o: %.i
	$(CC) $(CFLAGS) -c -o $@ $<

# cancel the built-in rules that we don't want to use
%.o: %.cc
%.o: %.cpp
%.o: %.c
%: %.o
%.o: %.s
