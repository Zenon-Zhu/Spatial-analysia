
library(sf)
library(ggplot2)
library(dplyr)
library(readr)
# 读取保护地区数据
protected_areas <- st_read("C:/Users/61723/Desktop/WDPA_WDOECM_Jan2024_Public_IDN_shp_1/WDPA_WDOECM_Jan2024_Public_IDN_shp-polygons.shp")

# 读取国家边界数据
country_boundary <- st_read("C:/Users/61723/Desktop/Spatial Assignment 2/idn_adm_bps_20200401_shp/idn_admbndl_admALL_bps_itos_20200401.shp")
# Create a buffer of 5 km around the roads
roads_buffer <- st_buffer(protected_areas, dist = 1500)



# 绘制地图
ggplot() +
  geom_sf(data = indonesia_boundary, fill = "blue") +
  geom_sf(data = roads_buffer, fill = "green", color = NA) +
  
  theme_minimal() +
  ggtitle("Protected areas distribution map")


