UNAME = $(shell uname)
ifeq ($(UNAME),Linux)
    CXX = g++
    CXXFLAGS = -m64 -fopenmp -O3 -DMKL
    LIB_DIR = /opt/intel/compilers_and_libraries/linux/lib/intel64
    LIBS = -pthread -lm -ldl
    MKL_ROOT = /opt/intel/compilers_and_libraries/linux/mkl
    MKL_LIB_DIR = $(MKL_ROOT)/lib/intel64
endif
ifeq ($(UNAME),Darwin)
    OMP_LIB_DIR = /opt/intel/oneapi/compiler/latest/mac/compiler/lib
    OMP_LIB_ADD = -Wl,-rpath,$(OMP_LIB_DIR)
    OMP_LIBS = -liomp5

    MKL_LIB_ADD = -Wl,-rpath,$(MKLROOT)/lib
    MKL_LIBS = -lmkl_intel_lp64 -lmkl_sequential -lmkl_core

    PLASMA_ROOT = /opt/plasma-20.9.20
    PLASMA_INC_DIR = $(PLASMA_ROOT)/include
    PLASMA_LIBS = $(PLASMA_ROOT)/lib/libcoreblas.a

    CXX = /usr/local/bin/g++-11
    CXXFLAGS = -m64 -fopenmp -O3 -DMKL -I$(PLASMA_INC_DIR)
    LDFLAGS = -L$(MKLROOT)/lib -L$(OMP_LIB_DIR)
    LIBS = $(MKL_LIB_ADD) $(MKL_LIBS) $(OMP_LIB_ADD) $(OMP_LIBS) $(PLASMA_LIBS) 
endif

all: NoFlush FlushLRU

NoFlush: NoFlush.o
	$(CXX) -o $@ $<  $(LDFLAGS) $(LIBS)

FlushLRU: MultCallFlushLRU.o
	$(CXX) -o $@ $<  $(LDFLAGS) $(LIBS)

$(CPP_OBJS): %.o: %.cpp
	$(CXX) -c $(CXXFLAGS) -o $@ $<

clean:
	rm -f *.o
