THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))

-include ../config.mk
TOOLSUB ?= $(dir $(realpath $(THIS_MAKEFILE)))/../contrib/toolsub

.PHONY: default
default: dbgcov dbgcov-tool

CXX_OBJS := $(patsubst %.cpp,%.o,$(wildcard *.cpp))

# This list occasionally needs updates when LLVM libraries are reorganised
dbgcov-tool: LDLIBS += \
        -lclangAST \
        -lclangASTMatchers \
        -lclangAnalysis \
        -lclangBasic \
        -lclangDriver \
        -lclangEdit \
        -lclangFrontend \
        -lclangFrontendTool \
        -lclangLex \
        -lclangParse \
        -lclangSema \
        -lclangEdit \
        -lclangRewrite \
        -lclangRewriteFrontend \
        -lclangStaticAnalyzerFrontend \
        -lclangStaticAnalyzerCheckers \
        -lclangStaticAnalyzerCore \
        -lclangCrossTU \
        -lclangIndex \
        -lclangSerialization \
        -lclangToolingCore \
        -lclangTooling \
        -lclangFormat
# LLVM 15 and later need clangSupport
# Comment this out if using an earlier version
dbgcov-tool: LDLIBS += \
        -lclangSupport
# LLVM 18 and later need clangAPINotes
# Comment this out if using an earlier version
dbgcov-tool: LDLIBS += \
        -lclangAPINotes

# LLVM 18 is known to work (and includes the preprocessor fix)
# See https://github.com/llvm/llvm-project/commit/241cceb9af844ef7d7a87124407a04b0a64991fe
LLVM_CONFIG ?= llvm-config-18

#$(CXX_OBJS): CXX := clang
$(CXX_OBJS): CXXFLAGS += -std=c++14 -fPIC -g `$(LLVM_CONFIG) --cxxflags` -UNDEBUG

dbgcov-tool: LDFLAGS += `$(LLVM_CONFIG) --ldflags`
dbgcov-tool: LDLIBS += `$(LLVM_CONFIG) --libs` `$(LLVM_CONFIG) --system-libs`
dbgcov-tool: main.o
	$(CXX) -o $@ $+ $(LDFLAGS) $(LDLIBS)

OCAMLOPTFLAGS += -fPIC
CFLAGS += -fPIC

OCAMLFIND ?= ocamlfind
OCAMLFLAGS +=  -package findlib -package dynlink
OCAMLFLAGS += -I $(dir $(THIS_MAKEFILE))/lib
OCAMLFLAGS += -I $(TOOLSUB)/wrapper/lib
vpath %.cmx $(TOOLSUB)/wrapper/lib
vpath %.o $(TOOLSUB)/wrapper/lib

OCAMLLIBS := str.cmxa unix.cmxa

dbgcov: compiler_args.cmx dbgcov.ml mkstemp_stubs.o
	$(OCAMLFIND) ocamlopt -o "$@" $(OCAMLOPTFLAGS) $(OCAMLFLAGS) $(OCAMLLIBS) $+ -linkpkg -linkall

%.cmxs: %.cmx
	$(OCAMLFIND) ocamlopt -shared -o "$@" $(OCAMLOPTFLAGS) $(OCAMLFLAGS) $+
%.cmx %.cmi: %.ml
	$(OCAMLFIND) ocamlopt -o "$@" $(OCAMLOPTFLAGS) $(OCAMLFLAGS) -c "$<"
%.cmo %.cmi: %.ml
	$(OCAMLFIND) ocamlc -o "$@" $(OCAMLFLAGS) -c "$<"
%.cma: %.cmo
	$(OCAMLFIND) ocamlc -o "$@" $(OCAMLFLAGS) -a $+

clean:
	rm -f *.o *.cmxa *.cmx *.cmo *.cmxs *.cmi
	rm -f dbgcov dbgcov-tool
