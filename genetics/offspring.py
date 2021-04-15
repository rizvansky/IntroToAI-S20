import numpy as np


class Offspring:
    def __init__(self, chromosome):
        """
        Initialize the Offspring class object.
        Chromosome is represented as a list of 1024 16x16 images' numbers
        Gene - 16x16 image's number
        """
        self.chromosome = chromosome

    def mutate(self, letters):
        """
        Mutate the chromosome.
        Change a random chromosome's gene random number of times (from 0 to 5)

        Args:
            self: Current offspring
            letters: List of the Numpy arrays with pixels of letters
        """
        times = np.random.randint(0, 6)
        for i in range(times):
            gene_index = np.random.randint(low=0, high=len(self.chromosome))
            gene = np.random.randint(low=0, high=len(letters))
            self.chromosome[gene_index] = gene

    def cross(self, second):
        """
        Perform the Uniform Order Crossover of two offsprings

        Args:
            self: Current offspring
            second: Second offspring for crossover

        Returns:
            New offspring obtained by the crossover (child of these two offsprings)
        """

        mask = np.random.rand(len(self.chromosome)) > 0.5
        crossover_chromosome = self.chromosome * mask + second.chromosome * (~mask)

        crossover_offspring = Offspring(crossover_chromosome)

        return crossover_offspring
