# Assignment 2

## Installing necessary packages
```
python -m pip install -r requirements.txt
```

## Test function simulation
* To run the genetic algorithm for a particular input image, it is needed to pass the path to the corresponding config file as a command line argument.
All config files are located at `./configs`. If needed, one can set his own config file.
* Example of how to run the genetic algorithm for the Mona Lisa portrait.
```
python main.py -c 'configs/mona_lisa.yaml'
```

## Details regarding the image generation process
* Each target image is approximated by the 16x16 images, and the folder with such images should be specified in the corresponding `.yaml` config file for each target image. I have chosen to use 16x16 pixels images of letters of Russian alphabet. For each target image, I have selected the particular set of letters and colors by which the approximation is done, for faster convergence, however, the implemented genetic algorithm works fine with any set of 16x16 images but may require slightly more time for convergence.
* If one wants to approximate its own image, he should prepare his `.yaml` config file. One can select the letters for approximation from the directory `letters/any`.
* Note: the genetic algorithm requires several hours for convergence. Also, keep in mind, that for different input images, different number of generations is required, so it is better to tune the parameters in the config file on your own. 

## Creating GIF animations
* You can also create GIFs to see the evolution process.
* Example of how to create GIF of the Mona Lisa portrait generation process.
```
python create_gif.py -c 'configs/mona_lisa.yaml'
```
* All GIFs are saved at the directory `./gifs`

## Examples
1. Mona Lisa (25000 generations)
![1](./gifs/mona_lisa.gif)

2. Doctor Brown (25000 generations)
![2](./gifs/doctor_brown.gif)

3. Naruto (25000 generations)
![3](./gifs/naruto.gif)

4. Avocado (25000 generations)
![4](./gifs/avocado.gif)
