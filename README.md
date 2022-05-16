# MorFishJ

<p align="left">
  <img src="readme_files/MorFishJ_logo.png" width="100" title="MorFishJ GUI"><br>
</p>

## Description

`MorFishJ` is a software package that allows to perform a standardised, reproducible, and semi-automated traditional morphometric analysis of fishes from side-view images. Because ImageJ is commonly used by researchers to extract morphometric data from fish images, `MorFishJ` has been developed as an extension of this software and it can be used in both ImageJ 1.x and Fiji (ImageJ2) distribution.

## Installation

To install `MorFishJ`:

1. Download MorFishJ:

- for people familiar with GitHub: clone or download the entire repository.
- for people not familiar with GitHub: click on the green button `Code` in the [project's main page on GitHub](https://github.com/mattiaghilardi/MorFishJ), then click on `Download ZIP`, thus extract the content.

2. Copy the `MorFishJ v0.0.1` folder in the `ImageJ/plugins/` or `Fiji.app/plugins/` directory.

`MorFishJ` depends on `ImageJ 1.53e`, thus, if ImageJ/Fiji was previously installed, first check the current ImageJ version below the toolbar. If it is older than 1.53e, to update ImageJ click **Help --> Update ImageJ...**, choose the latest version and click OK. Then ImageJ/Fiji must be restarted.

Open ImageJ/FIJI and click **Plugins --> MorFishJ v0.0.1 --> MorFishJ GUI**. The following GUI should appear in the upper left corner of the screen.

<p align="center">
  <img src="readme_files/MorFishJ_GUI_v0.0.1.png" width="300" title="MorFishJ GUI"><br>
</p>

In Fiji it may be easier to use the `Search` field under the toolbar to find and start `MorFishJ` as the Plugins menu is often crowded.

## Available analyses

Three morphometric analyses are currently available in `MorFishJ`:

- **Main Traits**: the workhorse of MorFishJ. Performs a complete morphometric analysis measuring 22 traits that cover all body parts visible from side view images, excluding dorsal, pelvic, and anal fins;
- **Head Angles**: allows to measure three head angles related to vision and feeding (Brandl and Bellwood 2013 *Coral Reefs*; Bellwood et al. 2014 *Proc R Soc B: Biol Sci*; Brandl et al. 2015 *Proc R Soc B: Biol Sci*);
- **Gut Traits**: allows to measure three intestinal traits related to fish diet (Ghilardi et al. 2021 *Ecol Evol*).

## User manual and tutorials

A step by step guide to the software can be found [here](https://mattiaghilardi.github.io/MorFishJ_manual/).

Tutorials covering the installation and use of `MorFishJ` will soon be available.

## Licenses

Licensed under the [MIT](https://github.com/mattiaghilardi/MorFishJ/blob/main/LICENSE) license.

## Contributing

Contributions are welcome. You can report bugs, ask questions or provide comments and feedback by filing an issue on Github [here](https://github.com/mattiaghilardi/MorFishJ/issues) or writing to mattia.ghilardi91@gmail.com. You can also suggest additional analyses that could be useful to others researchers. These will be discussed and potentially implemented.
