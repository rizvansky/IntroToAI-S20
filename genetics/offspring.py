import numpy as np


class Offspring:
    # Gene is the list of 1024 numbers of letter objects
    def __init__(self, gene):
        self.gene = gene

    def mutate(self, letters):
        """
        Mutate the gene.
        Change the gene's cell at the random place of gene sequence random number of times (from 0 to 5)

        Args:
            letters: List of the Numpy arrays with pixels of letters
        """
        times = np.random.randint(0, 6)
        for i in range(times):
            cell_index = np.random.randint(low=0, high=len(self.gene))
            cell = np.random.randint(low=0, high=len(letters))
            self.gene[cell_index] = cell
