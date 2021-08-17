#include <plasma.h>
#include <core_lapack.h>

#include "test.h"
#include "flops.h"

#include <iostream>
#include <cassert>
#include <cstdlib>

#include <omp.h>

int main(const int argc, const char **argv)
{
	if (argc < 6)
	{
		std::cerr << "usage: a.out [min M] [max M] [step M] [min NB size] [max NB size]\n";
		return EXIT_FAILURE;
	}

    const int minM = atoi(argv[1]);
	const int maxM = atoi(argv[2]);
    const int stepM = atoi(argv[3]);

    const int minNB = atoi(argv[4]);
	const int maxNB = atoi(argv[5]);

    const int itr = 5;

    std::cout << "m,nb,ib,time,gflops" << std::endl;

    // Initialize plasma
    plasma_init();

    for (int m=minM; m<=maxM; m+=stepM)
    {
        int seed[] = {0, 0, 0, m};

        int n = m;
        int lda = m;

        // Allocate and initialize arrays.
        double *A = new double[m*m];
        assert(A != NULL);

        assert(0 == LAPACKE_dlarnv(1, seed, (size_t)lda*n, A));

        for (int nb=maxNB; nb>=minNB; nb-=2)
        {
            for (int ib=2; ib<=nb/2; ib++)
            {
                if (nb % ib != 0)
                    continue;

                // Set tuning parameters
                plasma_set(PlasmaTuning, PlasmaDisabled);
                plasma_set(PlasmaNb, nb);
                plasma_set(PlasmaIb, ib);
                plasma_set(PlasmaHouseholderMode, PlasmaFlatHouseholder);

                // Prepare the descriptor for matrix T.
                plasma_desc_t T;

                for (int it=0; it<itr; it++)
                {
                    plasma_time_t start = omp_get_wtime();
                    plasma_dgeqrf(m, n, A, lda, &T);
                    plasma_time_t stop = omp_get_wtime();
                    plasma_time_t time = stop-start;

                    double flops = flops_dgeqrf(m, n) / time / 1e9;

                    std::cout << m << "," << nb << "," << ib << "," << time << "," << flops << std::endl;

                    assert(0 == LAPACKE_dlarnv(1, seed, (size_t)lda*n, A));
                }
            } // End of ib-loop
        } // End of nb-loop
        delete [] A;
    } // End of m-loop

   	return EXIT_SUCCESS;
}
