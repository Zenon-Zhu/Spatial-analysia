library(ncdf4) #library to read and process netcdf data
era <- nc_open("C:/Users/61723/Desktop/era5.nc" )
era #3 variables [u10, v10, ssrd], 3 dimensions [longitude,latitude,time] 
#get Dimension :lon, lat, time
lon <- ncvar_get(era, "longitude")
lat <- ncvar_get(era, "latitude")
time <- ncvar_get(era, "time")
time
dim(time) #you can also use dim() to try dim(lat) or dim(lon), and compare the results 
# get the unit of data
tunits <- ncatt_get(era,"time","units") #tunits <- ncatt_get(era,"longitude","units")
#The tunits says ""hours since 1900-01-01". Taking the first one as example.
#1043144
1900+ 1043144/ (24*365)
#1040288 actually is the data at 8am, 2019-Jan-29
#8am, 12pm, 4pm, 8pm.
#get the remainder. You will find that the time data comes in a group. For each group, there are four time period: 8, 12,16,20
(time[5]%%(24*365) ) %% 24 #2019-July-29
library(chron) #deal with chronological objects
#convert time -- split the time units string into fields
tustr <- strsplit(tunits$value, " ") #strsplit: split the element of character vector. we can convert  "hours since 1900-01-01" to "hours"      "since"      "1900-01-01"
tdstr <- strsplit(unlist(tustr)[3], "-") #convert "1900-01-01" to "1900" "01"   "01"
tyear <- as.integer(unlist(tdstr)[1]) 
tmonth <- as.integer(unlist(tdstr)[2])
tday <- as.integer(unlist(tdstr)[3])

chron(time/24, origin=c(tmonth, tday, tyear) ) #this function is of great help. It can convert the hours since format to the format we are quite familiar with.
#get Variables :u10,v10, ssrd. similar to get dimension data, we are going to use the same method, ncvar_get()
ssrd_array <- ncvar_get(era,"ssrd") #get the Surface solar radiation downwards
dim(ssrd_array) #dimension is 501 * 186 *8. Think about the Figure 1. The reason why it is called array is it is composed of 8 slices 
dlname <- ncatt_get(era,"ssrd","long_name")
dunits <- ncatt_get(era,"ssrd","units")
fillvalue <- ncatt_get(era,"ssrd","_FillValue")

library(lattice)
library(RColorBrewer)


#Get a single time slice of the data using ssrd_array
ssrd_slice <- ssrd_array[,,2] 
#The ssrd_slice is actually a matrix. class(ssrd_slice)
# What does 2 in ssrd_array[,,2] indicate?  What if I want to slice all four time slice for "07/01/19"? 

length(na.omit(as.vector(ssrd_slice))) /length(as.vector(ssrd_slice)) #8.5% are valid
dim(ssrd_slice )
library(RColorBrewer)

image(ssrd_slice, col=rev(brewer.pal(10,"RdBu")) )
#example: check one max point
max_rad <- max(ssrd_slice, na.rm=TRUE)
max_rad
lonlat <- as.matrix( (expand.grid(lon, lat))) #lon and lat are what we extracted in step 2.
dim(lonlat) #we now have a matrix that has 93186 rows and 2columns. 93186=501*186
ssrd_vec <- as.vector( ssrd_slice) 
length(ssrd_vec)
ssrd_df <- data.frame( cbind( lonlat,ssrd_vec  ))
colnames(ssrd_df) <- c("lon", "lat", "ssrd")
ssrd_df_value <- na.omit (ssrd_df)
head(ssrd_df_value, 3) 
#Creating a spatial object from a lat/lon table
library(sf)
ssrd_sf<- st_as_sf( ssrd_df_value, coords = c(  "lon", "lat")  ) #convert long and lat to point in simple feature format
#To make it a complete geographical object we assign the WGS84 projection, which has the EPSG code 4326
st_crs(ssrd_sf) <- 4326 
ssrd_sf <- st_transform(ssrd_sf, 4326 )

library(tmap)
tmap_mode("view")
tm_shape(ssrd_sf)+
  tm_dots(col="ssrd", style = "quantile", size=.001, palette = "viridis")
ncatt_get(era,"ssrd","units") #joul per metre2 
# an example of a 1m2 (A) solar panel
radiation_to_power <- function(G, A=1, r=0.175, p=0.6, hours=1){
  kWh <- G * A * r * p * (hours/3600) / 1000
  return(kWh)
}
# Radiation data for solar electric (photovoltaic) systems are often represented as kilowatt-hours per square meter (kWh/m2)
# 1 joule/m2 = 1/3600/1000 kWh / m2 (one 1KWh contains 3.6×106 Joules)
ssrd_kwh <- as.data.frame (radiation_to_power (ssrd_df_value))
ssrd_df_value <- cbind(ssrd_df_value,ssrd_kwh$ssrd)
colnames(ssrd_df_value) [4] <- 'ssrd_kwh'
ssrd_sf$ssrd_kwh = ssrd_kwh$ssrd

tm_shape(ssrd_sf)+
  tm_dots(col="ssrd_kwh", style = "quantile", size=.001, palette = "YlOrRd")
indonesia <-st_read("C:/Users/61723/Desktop/Spatial Assignment 2/idn_adm_bps_20200401_shp/idn_admbnda_adm3_bps_20200401.shp")
ssrd_sf = st_transform(ssrd_sf, 4326)
indonesia
indonesia = st_transform(indonesia, st_crs(ssrd_sf))

coor = as.data.frame(st_coordinates(ssrd_sf))
ssrd_sf$x = coor$X
ssrd_sf$y = coor$Y
ssrd_nogeom = st_drop_geometry(ssrd_sf) #get rid of geometry but keep all other attributes
ssrd_nogeom=na.omit(ssrd_nogeom)
# gstat::idw(formula, locations, ...) Function "idw" performs just as "krige" without a model being passed, but allows direct specification of the inverse distance weighting power. 
library(gstat)
gs <- gstat(formula=ssrd~1, locations=~x+y, data=ssrd_nogeom, nmax=Inf, set=list(idp=30)) #data should be in data frame format
gs
st_bbox(indonesia)
library(terra)
#1 degree = 111.1 km, so 0.01 is around 1.11km which is 1110 metre; 0.1 is 11.1km, roughly 11100 metre
raster_template = rast( resolution = 0.05,
                        xmin=95.01079 , ymin=-11.00762  ,xmax=141.01940 , ymax=6.07693  ,  crs = st_crs(indonesia)$wkt)
raster_template #check basic information about the raster template we created
idw <- interpolate(raster_template, gs, debug.level=0) #interpolate is the function comes with terra
plot(idw$var1.pred)
idw_mask <- mask(idw, indonesia)
plot(idw_mask$var1.pred)
names(idw_mask) = c( "predicted","observed" )
# 假设 idw_mask$predicted 包含预测的辐射量（Joule/m²）

idw_mask$kwh<- as.data.frame (radiation_to_power (idw_mask$predicted))
tmap_mode("view") #tmap can also do raster plot
tm_shape(idw_mask$kwh) + 
  tm_raster(col="kwh", style = "quantile", n = 10, palette= "YlOrRd", legend.show = TRUE)
