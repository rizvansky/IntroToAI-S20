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
            self: Current offspring
            letters: List of the Numpy arrays with pixels of letters
        """
        times = np.random.randint(0, 6)
        for i in range(times):
            cell_index = np.random.randint(low=0, high=len(self.gene))
            cell = np.random.randint(low=0, high=len(letters))
            self.gene[cell_index] = cell

    def cross(self, second):
        """
        Make crossover of two individuals

        Args:
            self: Current offspring
            second: Offspring class object, offspring for crossover

        Returns:
            New offspring obtained by the crossover (child of these two offsprings)
        """

        new_gene = []

        mask = np.random.rand(len(self.gene)) > 0.5
        new_gene = self.gene * mask + second.gene * (~mask)

        crossover_offspring = Offspring(new_gene)

        return crossover_offspring
