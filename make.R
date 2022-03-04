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


## Read IPBES Countries ----

world <- sf::st_read(here::here("data", "ipbes-regions", "ipbes_subregions_2",
                                "IPBES_Regions_Subregions2.shp"))

dotted <- sf::st_read(here::here("data", "ipbes-regions", "dotted_borders",
                                 "dotted_borders.shp"))

dashed <- sf::st_read(here::here("data", "ipbes-regions", "dashed_borders",
                                 "dashed_borders.shp"))

lakes <- sf::st_read(here::here("data", "ipbes-regions", "major_lakes",
                                "Major_Lakes.shp"))

grey_areas <- sf::st_read(here::here("data", "ipbes-regions", "grey_areas",
                                     "grey_areas.shp"))


## Project in Robinson ----

robin <-  "+proj=robin +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"

world      <- sf::st_transform(world, robin)
dotted     <- sf::st_transform(dotted, robin)
dashed     <- sf::st_transform(dashed, robin)
lakes      <- sf::st_transform(lakes, robin)
grey_areas <- sf::st_transform(grey_areas, robin)


## Read "Population relying on traditional use of biomass - 2018" Dataset ----
## Source: IEA, World Energy Outlook (2019)

biomasse <- readxl::read_excel(here::here("data", "pop_biomasse_2018.xlsx"),
                               sheet = 1)
biomasse <- as.data.frame(biomasse)


## Join Informations ----

world$"Pop_Biomasse" <- NA

for (i in 1:nrow(biomasse)) {
  
  lignes <- which(world$Area == biomasse[i, "country"])
  
  if (!length(lignes)) {
    stop(paste0(i, " : ", biomasse[i, "country"]))
  }
  world[lignes, "Pop_Biomasse"] <- biomasse[i, "pop"]
}


## Define Color Palette ----

world$"Color" <- NA

xrange <- data.frame(xmin = c(seq(  0,  10, by =   2), 
                              seq( 20, 100, by =  20), 
                              seq(200, 600, by = 200)))
xrange$xmax <- c(xrange$xmin[-1], 800)
xrange$xmin[1] <- 1
xrange$color_palette <- colorRampPalette(c("#f6d151", "#01A186"))(15)[-1]

for (i in 1:nrow(world)) {
  
  if (is.na(world[i, "Pop_Biomasse", drop = TRUE])) {
    
    world[i, "Color"] <- "#f0f0f0"
    
  } else {
    
    if (world[i, "Pop_Biomasse", drop = TRUE] == 0) {
      
      world[i, "Color"] <- colorRampPalette(c("#f6d151", "#01A186"))(15)[1]
      
    } else {
      
      ccolor <- which(xrange$xmin <= world[i, "Pop_Biomasse", drop = TRUE] & 
                        xrange$xmax >  world[i, "Pop_Biomasse", drop = TRUE])
      
      world[i, "Color"] <- xrange[ccolor, "color_palette"]
    }
  }
}

world[which(world$Area == "Antarctica"), "Color"] <- "white"


## Read Local wood fuels supply/demand balance Raster ----

ras <- raster::raster(here::here("data", 
                                 "WISDOM_Balance_x_IPBES_rep_Penny_Mograbi",
                                 "lbal_h_be2"))
ras <- raster::projectRaster(ras, crs = robin)


## Read location of major deficit sites ----

shp <- list.files(here::here("data", "WISDOM_Balance_x_IPBES_rep_Penny_Mograbi"),
                  full.names = TRUE, pattern = "\\.shp$")

shp <- lapply(shp, sf::st_read)
shp <- lapply(shp, function(x) x[ , c("def_fsum20")])
shp <- do.call(rbind.data.frame, shp)

shp <- sf::st_transform(shp, robin)

color_raster <- c("#5F1B1D", "#8B2325", "#A5362A", "#BA5135", "#E98054", "#E29A68", 
                  "#FAF6B8", "#C0D889", "#89B664", "#5F9645", "#3E7A3A", "#216032")
# raster::plot(x, 
#              breaks = c(-42462464, -40000, -10000, -500, -100, -25, -5, 5, 10, 25, 50, 100, 542060.1), 
#              col    = color_raster)
# 
# plot(sf::st_geometry(shp), cex = sqrt(range(shp$def_fsum20) / 1000000000 / (0.035 * pi)), add = TRUE)
# plot(sf::st_geometry(shp), cex = .25, col = "#CF262A", add = TRUE, pch = 19)

# Create Graticules ----

lat <- c( -90,  -60, -30, 0, 30,  60,  90)
lon <- c(-180, -120, -60, 0, 60, 120, 180)

grat <- graticule::graticule(
  lons = lon,
  lats = lat,
  proj = robin,
  xlim = range(lon),
  ylim = range(lat)
)



## Export Map ----

# png(here::here("figures", "ipbes-su-chap3-wood_fuel.png"),
#     width = 12, height = 15, units = "in", res = 600, pointsize  = 18)

svg(here::here("figures", "ipbes-su-chap3-wood_fuel.svg"),
    width = 12, height = 15, pointsize  = 18)

par(mar = rep(1, 4), family = "serif")
par(mfrow = c(2, 1))


##
## MAP (A) ----
##


col_sea  <- "#e5f1f6"
col_grat <- "#bfdde9"

sp::plot(grat, lty = 1, lwd = 0.2, col = "#c8c8c8")

plot(sf::st_geometry(world), col = world$Color, border = "#c8c8c8", lwd = 0.2, add = TRUE)

plot(sf::st_geometry(dotted), add = TRUE, col = "#f0f0f0", lwd = 0.2,
     lty = "solid")
plot(sf::st_geometry(dotted), add = TRUE, col = "#c8c8c8", lwd = 0.2,
     lty = "dotted")

plot(sf::st_geometry(dashed), add = TRUE, col = "#f0f0f0", lwd = 0.2,
     lty = "solid")
plot(sf::st_geometry(dashed), add = TRUE, col = "#c8c8c8", lwd = 0.2,
     lty = "dashed")

plot(sf::st_geometry(grey_areas), add = TRUE, col = "#a8a8a8", border = "#c8c8c8",
     lwd = 0.2)


## Add lakes ----

plot(sf::st_geometry(lakes), add = TRUE, col = col_sea, border = col_grat,
     lwd = 0.2)


## Legend ----

cols <- c("#F6D151", xrange$color_palette)

par(xpd = TRUE)

for (i in 1:15) {
  rect(xleft   = -7500000 + (i - 1) * 1000000, xright = -7500000 + i * 1000000,
       ybottom = -10500000 - 500000, ytop = -10500000 + 500000,
       col = cols[i], border = "#c8c8c8")
  if (i %in% c(2, 7, 12)) {
    text(-7500000 + (i - 1) * 1000000, -10500000 - 400000, pos = 1, 
         xrange[i - 1, "xmin"], cex = 0.7, col = "#666666")
  }
}

text(x = 0, y = -10000000, col = "#666666", font = 2, pos = 3, cex = 1,
     labels = "Population (in millions) relying on traditional use of biomass (2018)")
text(-16817530, 7500000, "a)", pos = 4, col = "#666666", font = 2, cex = 1)



##
## MAP (B) ----
##

sp::plot(grat, lty = 1, lwd = 0.2, col = "#c8c8c8")


plot(sf::st_geometry(world[which(world$Area != "Antarctica"), ]),
     col = "#eeeeee", border = NA, lwd = 0.2, add = TRUE)

raster::plot(ras,
             breaks = c(-42462464, -40000, -10000, -500, -100, -25, -5, 5, 10, 25, 50, 100, 542060.1),
             col    = paste0(color_raster, "de"), add = TRUE, legend = FALSE)

plot(sf::st_geometry(world),
     col = NA, border = "#c8c8c8", lwd = 0.2, add = TRUE)

plot(sf::st_geometry(world[which(world$Area == "Antarctica"), ]),
     col = "white", border = "#c8c8c8", lwd = 0.2, add = TRUE)

plot(sf::st_geometry(dotted), add = TRUE, col = "#f0f0f0", lwd = 0.2,
     lty = "solid")
plot(sf::st_geometry(dotted), add = TRUE, col = "#c8c8c8", lwd = 0.2,
     lty = "dotted")

plot(sf::st_geometry(dashed), add = TRUE, col = "#f0f0f0", lwd = 0.2,
     lty = "solid")
plot(sf::st_geometry(dashed), add = TRUE, col = "#c8c8c8", lwd = 0.2,
     lty = "dashed")

plot(sf::st_geometry(grey_areas), add = TRUE, col = "#a8a8a8", border = "#c8c8c8",
     lwd = 0.2)


## Add lakes ----

plot(sf::st_geometry(lakes), add = TRUE, col = col_sea, border = col_grat,
     lwd = 0.2)


## Add circles ----

plot(sf::st_geometry(shp), cex = sqrt(shp$def_fsum20 / 1000000000 / (0.05 * pi)), add = TRUE)
plot(sf::st_geometry(shp), cex = .25, col = "#CF262A", add = TRUE, pch = 19)



## Legend ----

# rect(-8800000, -8625155, 8800000, -5825155, col = "white", border = "#c8c8c8", lwd = 0.2)

cols <- color_raster
labels <- c(NA, "<-40,000", NA, "-500", NA, "-25", "-5", "5", "10", "25", NA, ">100", NA)
for (i in 1:length(cols)) {
  rect(xleft   = -6000000 + (i - 1) * 1000000, xright = -6000000 + i * 1000000,
       ybottom = -10500000 - 500000, ytop = -10500000 + 500000,
       col = cols[i], border = "#c8c8c8")
  if (!is.na(labels[i])) {
    text(-6000000 + (i - 1) * 1000000, -10500000 - 400000, pos = 1, labels[i], cex = 0.7, col = "#666666")
  }
}

text(x = 0, y = -10000000, col = "#666666", font = 2, pos = 3, cex = 1,
     labels = "Local wood fuels supply/demand balance (in woody oven-dry tons / year)")
text(-16817530, 7500000, "b)", pos = 4, col = "#666666", font = 2, cex = 1)



# rect(-16000000, -3000000, -10940000, 1250000, col = "white", border = "#c8c8c8", lwd = 0.2)

points(-15200000, -3000000, cex = sqrt(2.4 / (0.05 * pi)))
points(-15200000, -3000000, cex = .25, col = "#CF262A", pch = 19)
text(-14800000, -3000000, "Deficit = 2.4 Mt", pos = 4, cex = 0.9, col = "#666666")

points(-15200000, -1500000, cex = sqrt(1.4 / (0.05 * pi)))
points(-15200000, -1500000, cex = .25, col = "#CF262A", pch = 19)
text(-14800000, -1500000, "Deficit = 1.4 Mt", pos = 4, cex = 0.9, col = "#666666")

points(-15200000, -500000, cex = sqrt(0.4 / (0.05 * pi)))
points(-15200000, -500000, cex = .25, col = "#CF262A", pch = 19)
text(-14800000, -500000, "Deficit = 0.4 Mt", pos = 4, cex = 0.9, col = "#666666")

text(-13470000, 750000, "Major deficit sites", col = "#666666", font = 2)

dev.off()
