install.packages("sf")
install.packages("rgdal")
install.packages("dplyr")
install.packages("ggplot2")

library(sf)
library(rgdal)
library(dplyr)
library(ggplot2)


# 加载印度尼西亚国家边界
indonesia_country <- st_read("C:/Users/61723/Desktop/idn_adm_bps_20200401_shp/idn_admbndl_admALL_bps_itos_20200401.shp")

# 加载印度尼西亚道路
indonesia_roads <- st_read("C:/Users/61723/Desktop/IDN_rds/IDN_roads.shp")
# 基本可视化
ggplot() +
  geom_sf(data = indonesia_country, fill = "lightblue", color = "black") +
  geom_sf(data = indonesia_roads, color = "grey") +
  theme_minimal() +
  ggtitle("印度尼西亚道路地图")
