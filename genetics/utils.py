import numpy as np
from PIL import Image
from glob import glob
from offspring import Offspring


def fitness(img_array, target_img):
    """
    Fitness function

    Args:
        img_array: A [512, 512, 3] Numpy array of pixels of an image produced by genetic algorithm
        target_img: A 512x512 pixels target image to be approximated

    Returns:
        Mean Square Error between two arrays
    """
    return np.sum(1 / (512 * 512 * 3) * (target_img - img_array) * (target_img - img_array))


def sort_by_fitness(population):
    """
    Merge sort of population by the fitness error

    Args:
        population: An array with elements like: [offspring: Offspring, fitness: float]
    """
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


def set_letter(img_array, x, y, letter):
    """
    Fill with the given Numpy array [16, 16, 3] of pixels of the given letter the 16x16 pixels square with the top left
    corner at (x, y) in the 'img_array'

    Args:
        img_array: [512, 512, 3] Numpy array containing the pixels of the image
        x: X-coordinate where the letter will be set
        y: Y-coordinate where the letter will be set
        letter: Numpy array [16, 16, 3] of pixels of the given letter to be set
    """
    img_array[x: x + 16, y: y + 16, :] = letter


def load_letters(letters_dir):
    """
    Load the letter images from the given directory and return them in list

    Args:
        letters_dir: Path to the directory with 16x16 images with letters

    Returns:
        The list containing the loaded Numpy arrays [16, 16, 3] of pixels of letters
    """
    letters = []
    obj_paths = glob(f'{letters_dir}/*')

    for obj_path in obj_paths:
        obj = Image.open(obj_path)
        obj_arr = np.array(obj)
        letters.append(obj_arr)
        obj.close()

    return letters


def build_image(offspring, letters):
    """
    Construct an image using the offspring's chromosome. Note: 16x16 images must not intersect between each other.
    Each 16x16 image occupy only its part of an approximated image.

    Args:
         offspring: Offspring class object
         letters: List of the Numpy arrays with pixels of 16x16 letter images

    Returns:
        Numpy array [512, 512, 3] with pixels of an image
    """
    img_array = np.zeros([512, 512, 3], dtype=np.uint8)
    gene = offspring.chromosome
    index = 0
    for i in range(32):
        for j in range(32):
            if i == 31:
                x = 31 * 16 - 1
            else:
                x = i * 16
            if j == 31:
                y = 31 * 16 - 1
            else:
                y = j * 16

            set_letter(img_array, x, y, letters[gene[index]])

            index += 1

    return img_array


def init_population(population_size, target_img, letters):
    """
    Create the initial population

    Args:
        population_size: The size of the population
        target_img: The image to be approximated
        letters: List of the letter images

    Returns:
        The list with offsprings and their fitness
    """
    population = []

    for i in range(population_size):
        gene = []
        for j in range(1024):
            cell = np.random.randint(low=0, high=len(letters))
            gene.append(cell)

        offspring = Offspring(gene)
        fitness_value = fitness(build_image(offspring, letters), target_img)
        population.append([offspring, fitness_value])

    return population
