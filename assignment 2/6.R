library(raster)
library(ggplot2)
library(sf)
library(dplyr)

# 读取人口密度数据
population_density <- raster("C:/Users/61723/Desktop/idn_pop/idn_pop.grd")

# 读取国家边界数据
country_boundary <- st_read("C:/Users/61723/Desktop/Spatial Assignment 2/idn_adm_bps_20200401_shp/idn_admbndl_admALL_bps_itos_20200401.shp")

# 将raster对象转换为DataFrame，用于ggplot
population_density_df <- as.data.frame(population_density, xy = TRUE)
names(population_density_df) <- c("lon", "lat", "population_density")

# 创建分类变量
population_density_df$density_category <- ifelse(population_density_df$population_density > 50, "Suitable", "Unsuitable")

# 绘制地图
ggplot() +
  geom_raster(data = population_density_df, aes(x = lon, y = lat, fill = density_category), color = NA) + # 移除分割线
  geom_sf(data = country_boundary, fill = NA, color = NA) +
  scale_fill_manual(values = c("Suitable" = "blue", "Unsuitable" = "green")) +
  labs(fill = "Density Category", 
       title = "Population Density Distribution Map",
       x = "Longitude", 
       y = "Latitude") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
