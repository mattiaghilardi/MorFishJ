# MorFishJ v0.2.1

- Improved messages within dialogs.
- Improved code with more recent built-in ImageJ macro functions.
- MorFishJ now depends on ImageJ 1.53s. 
- Now the outlines of the body and eye in the `Main Traits` and `Head Angles` analyses are saved together with the other ROIs.

# MorFishJ v0.2.0

- The reference scale for the `Main Traits` analysis is now optional and any image, with and without scale, can be analysed. There are three options:
  - Add a scale through a reference object in the image -> the scale (pixels / cm) will be saved in the column `px.cm` of the results file as in the previous version;
  - Add a scale through the known length of the fish -> the scale (pixels / cm) will be saved in the column `px.cm`;
  - Do not add a scale to the image -> the column `px.cm` will display `NA`.

- The results of the `Main Traits` analysis are now saved in `pixels` instead of `cm`. If preferred, the column `px.cm` allows to convert them to `cm` when a scale is provided. 
- Removed version number from the plugin folder.

The user manual for this release can be found [here](https://mattiaghilardi.github.io/MorFishJ_manual/v0.2.0/).

# MorFishJ v0.1.0

This is the initial release of MorFishJ.

The user manual for this release can be found [here](https://mattiaghilardi.github.io/MorFishJ_manual/v0.1.0/).