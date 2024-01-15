
library(sf)
library(ggplot2)# 安装和加载所需的包

library(raster)

# 加载高程数据
elevation <- raster("C:/Users/61723/Desktop//IDN_msk_alt.vrt")

# 计算坡度
slope <- terrain(elevation, opt = 'slope')
# 将坡度数据分类：坡度小于或等于10的区域为0，大于10的区域为1
slope_classified <- reclassify(slope, cbind(c(-Inf, 10, 10, Inf), c(0, 0, 1, 1)))
slope_sf <- as(slope_classified, "SpatialPixelsDataFrame")
slope_sf <- st_as_sf(slope_sf)
# 加载保护区域和边界数据
protected_areas <- st_read("C:/Users/61723/Desktop/WDPA_WDOECM_Jan2024_Public_IDN_shp_1/WDPA_WDOECM_Jan2024_Public_IDN_shp-points.shp")
indonesia_boundary <- st_read("C:/Users/61723/Desktop/idn_adm_bps_20200401_shp/idn_admbndl_admALL_bps_itos_20200401.shp")

# 绘制地图
ggplot() +
  geom_sf(data = indonesia_boundary, fill = "white", color = "black") +
  geom_sf(data = protected_areas, color = "green") +
  geom_sf(data = slope_sf, aes(color = factor(slope_sf[["slope"]])), size = 0.5) +
  scale_color_manual(values = c("1" = "black", "0" = "green")) +
  theme_minimal() +
  ggtitle("Protected Areas and Slope in Indonesia")