install.packages(c("sf", "raster", "ggplot2"))
library(sf)
library(raster)
library(ggplot2)
indonesia_boundary <-st_read("C:/Users/61723/Desktop/Spatial Assignment 2/idn_adm_bps_20200401_shp/idn_admbnda_adm3_bps_20200401.shp")
population_density <- raster("C:/Users/61723/Desktop/Spatial Assignment 2/idn_pd_2020_1km.tif")

# 将栅格数据转换为数据框
population_density_df <- as.data.frame(population_density, xy = TRUE)

# 绘制图形
ggplot() +
  geom_raster(data = population_density_df, aes(x = x, y = y, fill = idn_pd_2020_1km)) +
  geom_sf(data = indonesia_boundary, color = "black", fill = NA) +
  scale_fill_viridis_c() +
  labs(title = "Map of population density and administrative divisions in Indonesia", x = "Longitude", y = "Latitude", fill = "Population Density") +
  coord_sf() + # 使用 coord_sf()
  theme_minimal()