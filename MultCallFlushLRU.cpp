#include <iostream>
#include <algorithm>
#include <cstdlib>
#include <cassert>
#include <ctime>
#include <omp.h>
#include <mkl.h>

using namespace std;

int main(const int argc, const char **argv)
{
	if (argc < 3)
	{
		cerr << "usage: a.out [min size] []\n";
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}
