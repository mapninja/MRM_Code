SELECT 
  ST_CENTROID(the_geom) AS centroid, 
  ST_GEOGFROMTEXT(
    CONCAT(
      'POLYGON((',
      bbox.xmin, ' ', bbox.ymin, ', ',
      bbox.xmin, ' ', bbox.ymax, ', ',
      bbox.xmax, ' ', bbox.ymax, ', ',
      bbox.xmax, ' ', bbox.ymin, ', ',
      bbox.xmin, ' ', bbox.ymin, '))'
    )
  ) AS bbox_geography, 
  * 
FROM (
  SELECT 
    *, 
    ST_BOUNDINGBOX(the_geom) AS bbox 
  FROM `sul-g-earth-engine-access.machines_reading_maps.mrm_v3_cleaned_annotations_with_geom`
)
LIMIT 1000;