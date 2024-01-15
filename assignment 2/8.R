library(sf)
library(raster)

# Read the shapefiles
indonesia_roads <- st_read("C:/Users/61723/Desktop/IDN_rds/IDN_roads.shp")
indonesia_admin <- st_read("C:/Users/61723/Desktop/idn_adm_bps_20200401_shp/idn_admbndl_admALL_bps_itos_20200401.shp")

# Create a buffer of 5 km around the roads
roads_buffer <- st_buffer(indonesia_roads, dist = 5000)

# Plot the map

plot(st_geometry(indonesia_admin), col = NA, main = "Indonesia Map with Roads")
plot(st_geometry(roads_buffer), col = 'green', add = TRUE, alpha = 0.5)
plot(st_geometry(indonesia_roads), col = 'grey', add = TRUE, lwd = 1.5)

# Add a legend
legend("topright", legend=c("Suitable", "Unsuitable"), 
       fill=c("blue", "green"), border=NA, bty = "n", cex = 0.7)