WITH geography_data AS (
    SELECT ST_GEOGFROMTEXT('POLYGON((-122.084 37.422, -122.084 37.426, -122.078 37.426, -122.078 37.422, -122.084 37.422))') AS polygon
)
SELECT
    ST_GEOGFROMTEXT(
        CONCAT(
            'POLYGON((',
            STRING_AGG(
                CONCAT(
                    ROUND(ST_X(geom), 3), ' ', ROUND(ST_Y(geom), 3)
                ),
                ', '
            ),
            '))'
        )
    ) AS polygon_with_reduced_precision
FROM (
    SELECT ST_DUMP(ST_BOUNDARY(polygon)).geom
    FROM geography_data
);
