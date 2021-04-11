from PIL import Image
import argparse
import yaml

if __name__ == '__main__':
    # Parse command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('--config', '-c')
    args = parser.parse_args()

    # Get the config path from the command line argument and read the config file
    config_path = args.config
    with open(config_path) as f:
        config = yaml.safe_load(f)

    images = []

    counter = 0
    step = config['num_generations'] // config['samples_to_save']
    for i in range(config['samples_to_save']):
        if counter == 0:
            img_path = f'{config["output_dir"]}/{config["target_img_alias"]}/generation{1}.png'
        else:
            img_path = f'{config["output_dir"]}/{config["target_img_alias"]}/generation{counter}.png'

        img = Image.open(img_path)
        images.append(img)
        counter += step

    save_gif_path = f'{config["output_dir"]}/{config["target_img_alias"]}/evolution.gif'
    images[0].save(save_gif_path, save_all=True, append_images=images[1:], duration=0.001, loop=0)

    for img in images:
        img.close()
