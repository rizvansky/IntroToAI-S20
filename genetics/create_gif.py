from PIL import Image
import argparse
import yaml
import numpy as np

if __name__ == '__main__':
    # Parse command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('--config', '-c')
    args = parser.parse_args()

    # Get the config path from the command line argument and read the config file
    config_path = args.config
    with open(config_path) as f:
        config = yaml.safe_load(f)

    target_img = Image.open(config['target_img_path'])
    target_img_array = np.array(target_img)

    images = []

    counter = 0
    step = (config['num_generations'] // config['samples_to_save'])
    STRIDE = 2

    for i in range(config['samples_to_save'] // STRIDE):
        if counter == 0:
            img_path = f'{config["output_dir"]}/{config["target_img_alias"]}/generation{1}.png'
        else:
            img_path = f'{config["output_dir"]}/{config["target_img_alias"]}/generation{counter}.png'

        img = Image.open(img_path)
        img_array = np.array(img)

        gif_frame_array = np.concatenate([target_img_array, img_array], axis=1)
        gif_frame = Image.fromarray(gif_frame_array)

        images.append(gif_frame)

        counter += step * STRIDE

    save_gif_path = f'gifs/{config["target_img_alias"]}.gif'
    images[0].save(save_gif_path, save_all=True, append_images=images[1:], duration=1, loop=0)

    for img in images:
        img.close()
