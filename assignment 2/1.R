library(sf)
library(raster)
#install.packages("rgeos")

library(sf)

# Read road data
roads <- st_read("C:/Users/61723/Desktop/IDN_rds/IDN_roads.shp")

# Read Indonesia boundary
indonesia_boundary <-st_read("C:/Users/61723/Desktop/Spatial Assignment 2/idn_adm_bps_20200401_shp/idn_admbnda_adm3_bps_20200401.shp")
# Create a buffer of 5 km around the roads
roads_buffer <- st_buffer(roads, dist = 5000)
# Plot the map
plot(st_geometry(indonesia_boundary), col = 'lightblue', main = "Indonesia Map with Roads")
plot(st_geometry(roads), col = 'grey', add = TRUE)
plot(st_geometry(roads_buffer), col = 'pink', add = TRUE, alpha = 0)









# Add a legend
legend("topright", legend=c("Roads", "5km Buffer Zone"), fill=c("grey", "pink"), border=NA)