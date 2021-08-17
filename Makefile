UNAME = $(shell uname)
ifeq ($(UNAME),Linux)
    PLASMA_ROOT = /opt/plasma-20.9.20
    PLASMA_INC_DIR = $(PLASMA_ROOT)/include
    PLASMA_LIB_DIR = $(PLASMA_ROOT)/lib
    PLASMA_LIBS = $(PLASMA_LIB_DIR)/libplasma.a $(PLASMA_LIB_DIR)/libcoreblas.a

    LIB_DIR = /opt/intel/compilers_and_libraries/linux/lib/intel64
    LIBS = -pthread -lm -ldl
    MKL_LIB_DIR = $(MKLROOT)/lib/intel64
    MKL_LIBS = -lmkl_intel_lp64 -lmkl_sequential -lmkl_core

    CXX = icpc
    CXXFLAGS = -fopenmp -O3 -DHAVE_MKL -I$(PLASMA_INC_DIR)
#    LDFLAGS = -L$(LIB_DIR) -L$(MKL_LIB_DIR) 
    LIBS = $(MKL_LIBS) $(PLASMA_LIBS) 
endif
ifeq ($(UNAME),Darwin)
    OMP_LIB_DIR = /opt/intel/oneapi/compiler/latest/mac/compiler/lib
    OMP_LIB_ADD = -Wl,-rpath,$(OMP_LIB_DIR)
    OMP_LIBS = -liomp5

    MKL_LIB_ADD = -Wl,-rpath,$(MKLROOT)/lib
    MKL_LIBS = -lmkl_intel_lp64 -lmkl_sequential -lmkl_core

    PLASMA_ROOT = /opt/plasma-20.9.20
    PLASMA_INC_DIR = $(PLASMA_ROOT)/include
    PLASMA_LIBS = $(PLASMA_ROOT)/lib/libcoreblas.a $(PLASMA_ROOT)/lib/libplasma.a

    CXX = /usr/local/bin/g++-11
    CXXFLAGS = -m64 -fopenmp -O3 -DHAVE_MKL -I$(PLASMA_INC_DIR) -I$(MKLROOT)/include
    LDFLAGS = -L$(MKLROOT)/lib -L$(OMP_LIB_DIR)
    LIBS = $(MKL_LIB_ADD) $(MKL_LIBS) $(OMP_LIB_ADD) $(OMP_LIBS) $(PLASMA_LIBS) 
endif

all: NoFlush FlushLRU PSPAYG

PSPAYG: pspayg.o
	$(CXX) $(CXXFLAGS) -o $@ $<  $(LDFLAGS) $(LIBS)

NoFlush: NoFlush.o
	$(CXX) $(CXXFLAGS) -o $@ $<  $(LDFLAGS) $(LIBS)

FlushLRU: MultCallFlushLRU.o
	$(CXX) $(CXXFLAGS) -o $@ $<  $(LDFLAGS) $(LIBS)

$(CPP_OBJS): %.o: %.cpp
	$(CXX) -c $(CXXFLAGS) -o $@ $<

clean:
	rm -f *.o
