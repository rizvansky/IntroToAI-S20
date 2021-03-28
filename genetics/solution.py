import numpy as np
import cv2
import os
import operator
import tqdm


class Individual:
    def __init__(self, gene, fitnessError=None):
        self.gene = gene
        self.fitnessError = fitnessError
        self.img = self.buildImageFromGene()

    def mutate(self):
        for i in range(5):
            x = np.random.randint(0, 10)
            if 9 >= x >= 2:
                numPts = np.random.randint(3, 7)
                centerX, centerY = np.random.randint(0, 512), np.random.randint(0, 512)
                pts = []
                for i in range(numPts):
                    pointX = self.generateCoord(centerX)
                    pointY = self.generateCoord(centerY)
                    point = np.array([pointX, pointY], dtype=np.int32)
                    pts.append(point)

                pts = np.array(pts)
                color = (np.random.randint(0, 256), np.random.randint(0, 256), np.random.randint(0, 256))
                self.gene.append([pts, color])

    def buildImageFromGene(self):
        if len(self.gene) == 0:
            return np.zeros(shape=[512, 512, 3])

        overlay = self.img.copy()

        pts = self.gene[len(self.gene) - 1][0]
        color = self.gene[len(self.gene) - 1][1]

        cv2.fillConvexPoly(overlay, pts, color)

        alpha = 1
        self.img = cv2.addWeighted(overlay, alpha, self.img, 1 - alpha, 0)

        return self.img.astype(np.uint8)

    def eval_error(self, true_img):
        generatedImg = self.buildImageFromGene()
        self.fitnessError = np.sum((true_img - generatedImg) * (true_img - generatedImg)) / (512 * 512 * 3)

    def generateCoord(self, centerCoord):
        coord = centerCoord + np.random.randint(-8, 8)
        if 512 > coord >= 0:
            return coord

        return self.generateCoord(centerCoord)


def make_art(num_generations, pop_size, true_img):
    # Generate initial population
    population = []

    for i in range(pop_size):
        initial_gene = []
        ind = Individual(gene=initial_gene)
        ind.eval_error(true_img=true_img)
        population.append(ind)

    # Genetic algorithm
    counter = tqdm.tqdm(total=num_generations + 1, desc='Generations', position=0)
    for i in range(num_generations):

        # Sort objects by fitness and select the best half
        population.sort(key=operator.attrgetter('fitnessError'))
        # print(population[0].fitnessError, population[len(population) - 1].fitnessError)
        generatedImg = population[0].buildImageFromGene()
        if i % 1000 == 0:
            cv2.imwrite(f'./logs/gen{i}.png', generatedImg)
        next_gen = population[0: len(population) // 2]

        # Mutate other half of the population
        for j in range(len(population) // 2, len(population)):
            population[j].mutate()
            population[j].eval_error(true_img=true_img)
            next_gen.append(population[j])

        population = next_gen
        counter.update(1)

    population.sort(key=operator.attrgetter('fitnessError'))

    return population[0]


def main():
    numGenerations = 50000
    popSize = 10
    inputImagesDir = './input'
    inputImagesNames = ['1.png']
    for input_image_name in inputImagesNames:
        input_image_path = os.path.join(inputImagesDir, input_image_name)
        input_img = cv2.imread(input_image_path)

        output_img = make_art(numGenerations, popSize, input_img)
        cv2.waitKey(0)


if __name__ == '__main__':
    main()
