## IPBES Sustainable Use of Wild Species Assessment - Chapter 3 - Data management report for the figures 3.58

[![License: CC BY SA 4.0](https://img.shields.io/badge/License-CC%20BY%20SA%204.0-lightgreen.svg)](https://creativecommons.org/licenses/by-sa/4.0/)

This repository contains the code to reproduce the Figure 3.58 of 
the Chapter 3 of the **IPBES Sustainable Use of Wild Species Assessment**. 

For more information: https://zenodo.org/record/6513849

![](figures/ipbes-su-chap3-wood_fuel.png)


## System Requirements

This project handles spatial objects with the R package
[`sf`](https://cran.r-project.org/web/packages/sf/index.html). This
package requires some system dependencies (GDAL, PROJ and GEOS). Please
visit [this page](https://github.com/r-spatial/sf/#installing) to
correctly install these tools.


## Usage

First clone this repository, then open the R script `make.R` and run it.
This script will read data stored in the folder `data/` and export the figure
in the folder `figures/`.


## License

This work is licensed under 
[Creative Commons Attribution-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-sa/4.0/).

Please cite this work as: 

> Penelope J. Mograbi, & Nicolas Casajus. (2022). IPBES Sustainable Use of Wild Species Assessment - Chapter 3 - Data management report for the figures 3.58. Zenodo. https://doi.org/10.5281/zenodo.6513849.

