import tqdm
import yaml
import argparse
from utils import *
import os


if __name__ == '__main__':

    # Parse command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('--config', '-c', default='./configs/standard.yaml')
    args = parser.parse_args()

    # Get the config path from the command line argument and read the config file
    config_path = args.config
    with open(config_path) as f:
        config = yaml.safe_load(f)

    # Initializations
    population_size = config['population_size']
    num_generations = config['num_generations']
    target_img_path = config['target_img_path']
    target_img_alias = config['target_img_alias']
    output_dir = config['output_dir']
    letters_dir = config['letters_dir']
    samples_to_save = config['samples_to_save']

    target_img = Image.open(target_img_path)                              # target image
    letters = load_letters(letters_dir)                                   # letters for image approximation
    save_every = num_generations // samples_to_save                       # saving frequency

    population = init_population(population_size, target_img, letters)    # population initialization

    # Creating necessary directories if needed
    if not os.path.isdir(output_dir):
        os.mkdir(output_dir)

    save_dir = f'{output_dir}/{target_img_alias}'

    if not os.path.isdir(save_dir):
        os.mkdir(save_dir)

    # Genetic algorithm
    counter = tqdm.tqdm(total=num_generations, desc='Generations', position=0, leave=True)  # logging generations
    fitness_log = tqdm.tqdm(total=0, position=1, bar_format='{desc}', leave=True)           # logging fitness
    for i in range(num_generations):
        
        # Sort the whole population by fitness values
        sort_by_fitness(population)

        # Crossover of top 20% of the population: crossed offsprings are stored at 'crossover_offsprings' list
        crossover_offsprings = []
        for k in range(int(population_size * 0.2)):
            for m in range(int(population_size * 0.2)):
                if k != m:
                    crossover_offspring = crossover(population[k][0], population[m][0])
                    crossover_offspring_fitness = fitness(build_image(crossover_offspring, letters), target_img)
                    crossover_offsprings.append([crossover_offspring, crossover_offspring_fitness])

        # Sort obtained after the crossover offsprings by fitness values
        sort_by_fitness(crossover_offsprings)

        # Include best crossed offsprings to the next 20% of the future generation
        population[int(population_size * 0.1): int(population_size * 0.3)] = crossover_offsprings[0: int(population_size * 0.2)]

        # Mutate all offsprings except top 10% of the population which goes to the next generation without changes
        for j in range(int(population_size * 0.1), population_size):
            population[j][0].mutate(letters)
            img_array = build_image(population[j][0], letters)
            population[j][1] = fitness(img_array, target_img)

        # Logging and saving intermediate images
        if i == 0 or (i + 1) % save_every == 0:
            pil_img = Image.fromarray(build_image(population[0][0], letters))
            pil_img.save(f'{save_dir}/generation{i + 1}.png')

        fitness_log.set_description_str(f'Current fitness: {population[0][1]}')
        counter.update(1)
