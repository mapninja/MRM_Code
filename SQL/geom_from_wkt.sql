SELECT ST_GEOGFROMTEXT(WKT, make_valid => TRUE) AS the_geom, *  
FROM `sul-g-earth-engine-access.machines_reading_maps.mrm_v3_cleaned_annotations`
