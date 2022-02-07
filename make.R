#' IPBES Sustainable Use Assessment - Figure Chapter 3 - Traditional biomass and Wood fuel
#' 
#' This R script reproduces the Figure 'Traditional biomass and Wood fuel' of 
#' the chapter 3 of the IPBES Sustainable Use Assessment. This figure shows  
#' two maps: a) the population relying on traditional biomass and b) the local 
#' wood fuel supply/demand balance.
#' 
#' @author Nicolas Casajus <nicolas.casajus@fondationbiodiversite.fr>
#' @date 2022/02/08



## Install `remotes` package ----

if (!("remotes" %in% installed.packages())) install.packages("remotes")


## Install required packages (listed in DESCRIPTION) ----

remotes::install_deps(upgrade = "never")


## Load project dependencies ----

devtools::load_all(".")

