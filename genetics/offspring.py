import numpy as np


class Individual:
    # Gene is the list of 1024 indexes of letter objects
    def __init__(self, gene):
        self.gene = gene

    '''
    Mutate the gene. Change the gene's cell at the random place of gene sequence.
    '''
    def mutate(self):
        cell_index = np.random.randint(low=0, high=self.gene_length)
        cell = np.random.randint(low=0, high=len(self.letters))
        self.gene[cell_index] = cell
