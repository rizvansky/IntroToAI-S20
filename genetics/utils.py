import numpy as np
from PIL import Image
from glob import glob

'''
Fitness function is the Mean Square Error loss
'''


def fitness(fake_img, true_img):
    return np.sum(1 / (512 * 512 * 3) * (true_img - fake_img) * (true_img - fake_img))


'''
Merge sort of population by the fitness function.
'''


def sort_by_fitness(population):
    if len(population) > 1:
        left = population[: len(population) // 2]
        right = population[len(population) // 2:]

        sort_by_fitness(left)
        sort_by_fitness(right)

        i = 0
        j = 0
        k = 0

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
Generate valid coordinates for the 16x16 image to be inserted
'''


def generate_coords():
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

    return x, y


'''
Insert the 16x16 image into the generated image.
This function is used for mutation.
'''


def fill_image(mutant, x, y, images_to_fill):
    img_to_fill = images_to_fill[np.random.randint(0, len(images_to_fill))]
    mutant[x: x + 16, y: y + 16, :] = img_to_fill


'''
Function that loads the images from the given directory and returns them in list
'''


def load_images(img_dir):
    images_to_fill = []
    obj_paths = glob(f'{img_dir}/*')

    for obj_path in obj_paths:
        obj = Image.open(obj_path)
        obj_arr = np.array(obj)
        images_to_fill.append(obj_arr)
        obj.close()

    return images_to_fill


'''
Function that creates the initial population
'''


def create_initial_population(population_size, input_img):
    population = []

    blank = np.zeros(shape=[512, 512, 3], dtype=np.uint8)
    initial_fitness = fitness(blank, input_img)
    for i in range(population_size):
        population.append([blank.copy(), initial_fitness])

    return population


'''
Mutation function
Performs <num_mutations> random mutations on one sample, selects the best mutation according to fitness function and 
includes this mutant in the list of mutants to be returned to the caller.
'''


def mutate(to_mutate, num_mutations, input_img, images_to_fill):
    mutated = []
    for i in range(len(to_mutate)):
        best = [None, None]
        for j in range(num_mutations):
            mutant = to_mutate[i][0].copy()
            x, y = generate_coords()
            fill_image(mutant, x, y, images_to_fill)
            current_fitness = fitness(mutant, input_img)

            # Select the mutant with the best mutation to return
            if best[1] is None:
                best = [mutant, current_fitness]
            elif current_fitness < best[1]:
                best = [mutant, current_fitness]

        mutated.append(best)

    return mutated
