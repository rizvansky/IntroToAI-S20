import tqdm
import yaml
import argparse
from utils import *
import os


def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('--config', '-c', default='./configs/standard.yaml')
    args = parser.parse_args()

    # Get the config path from the command line argument and read the config file
    config_path = args.config
    with open(config_path) as f:
        config = yaml.safe_load(f)

    # Initializations
    input_img = Image.open(config['input_img_path'])
    population_size = config['population_size']
    num_generations = config['num_generations']
    images_to_fill_dir = config['images_to_fill_dir']
    images_to_fill = load_images(images_to_fill_dir)
    samples_to_save = config['samples_to_save']
    save_every = num_generations // samples_to_save
    population = create_initial_population(population_size, input_img, images_to_fill)

    if not os.path.isdir('./output'):
        os.mkdir('./output')

    if not os.path.isdir(f'./output/{config["input_img_alias"]}'):
        os.mkdir(f'./output/{config["input_img_alias"]}')

    save_dir = f'./output/{config["input_img_alias"]}'

    counter = tqdm.tqdm(total=num_generations, desc='Generations', position=0)
    for i in range(num_generations):
        sort_by_fitness(population)
        if i == 0 or (i + 1) % save_every == 0:
            pil_img = Image.fromarray(population[0][0])
            pil_img.save(f'{save_dir}/generation{i + 1}.png')
            print(f'\nGeneration {i + 1}, fitness = {population[0][1]}')
        best_half = population[0: len(population) // 2]
        to_mutate = population[len(population) // 2: len(population)]
        mutated = mutate(to_mutate, 30, input_img, images_to_fill)

        population = best_half + mutated
        counter.update(1)

    sort_by_fitness(population)
    pil_img = Image.fromarray(population[0][0])
    pil_img.save(f'{save_dir}/generation{num_generations}.png')


if __name__ == '__main__':
    main()
