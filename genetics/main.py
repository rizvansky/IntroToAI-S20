import numpy as np
from PIL import ImageFont, ImageDraw, Image
import tqdm

POPULATION_SIZE = 1
NUM_GENERATIONS = 500000
ALPHABET = ['0', '1', 'X', 'Y', '+', '=', '/', '|', ';', '[', ']', '<', '>', '!', '-', '?', '$', '@', '%', '&', '*',
            '(', ')', '#', 'Q', 'S', 'R', '^']
FONT = ImageFont.truetype('Rubik-Regular.ttf', 15)


def fitness(fake_img, true_img):
    return np.sum(1 / (512 * 512 * 3) * (true_img - fake_img) * (true_img - fake_img))


'''
Merge sort of population by the fitness function
The code for merge sort is adopted and changed according to my needs from https://www.geeksforgeeks.org/merge-sort/
'''


def sort_by_fitness(population):
    if len(population) > 1:
        mid = len(population) // 2
        left = population[: mid]
        right = population[mid:]

        sort_by_fitness(left)
        sort_by_fitness(right)

        i = j = k = 0

        while i < len(left) and j < len(right):
            if left[i][1] < right[j][1]:
                population[k] = left[i]
                i += 1
            else:
                population[k] = right[j]
                j += 1
            k += 1

        while i < len(left):
            population[k] = left[i]
            i += 1
            k += 1

        while j < len(right):
            population[k] = right[j]
            j += 1
            k += 1


'''
Mutation function
Performs 10 random mutations on one sample, selects the best mutation according to fitness function and includes this
mutant in the list of returned mutants
'''


def mutate(to_mutate, num_mutation_trials, true_img):
    mutated = []
    for i in range(len(to_mutate)):
        best_fitness = -1
        best = -1
        for j in range(num_mutation_trials):
            mutant = to_mutate[i][0].copy()
            x, y = np.random.randint(0, 32), np.random.randint(0, 32)
            if x == 0:
                x = 0
            elif y == 0:
                y = 0
            elif x == 31:
                x = 31 * 16 - 1
            elif y == 31:
                y = 31 * 16 - 1
            else:
                x, y = x * 16, y * 16

            letter = np.zeros(shape=[16, 16, 3], dtype=np.uint8)
            pil_letter = Image.fromarray(letter)
            draw = ImageDraw.Draw(pil_letter)
            color = (np.random.randint(0, 256), np.random.randint(0, 256), np.random.randint(0, 256))
            text = ALPHABET[np.random.randint(low=0, high=len(ALPHABET))]
            draw.text((0, 0), text, font=FONT, fill=color)
            letter = np.array(pil_letter)
            mutant[x: x + 16, y: y + 16, :] = letter

            current_fitness = fitness(mutant, true_img)

            if best_fitness == -1:
                best_fitness = current_fitness
                best = [mutant, best_fitness]
            elif current_fitness < best_fitness:
                best_fitness = current_fitness
                best = [mutant, best_fitness]

        mutated.append(best)

    return mutated


def main():
    true_img = Image.open('./input/1.png')

    population = []
    empty_img = np.zeros(shape=[512, 512, 3], dtype=np.uint8)
    initial_fitness = fitness(empty_img, true_img)
    for i in range(POPULATION_SIZE):
        population.append([empty_img.copy(), initial_fitness])

    counter = tqdm.tqdm(total=NUM_GENERATIONS, desc='Generations', position=0)
    for i in range(NUM_GENERATIONS):
        sort_by_fitness(population)
        if i % 100 == 0:
            pil_img = Image.fromarray(population[0][0])
            pil_img.save(f'./output/gen{i + 1}.png')
        best_half = population[0: len(population) // 2]
        to_mutate = population[len(population) // 2: len(population)]
        mutated = mutate(to_mutate, 10, true_img)

        population = best_half + mutated
        counter.update(1)

    sort_by_fitness(population)


if __name__ == '__main__':
    main()
