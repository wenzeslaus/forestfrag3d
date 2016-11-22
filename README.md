# forestfrag3d

## Files

### Point cloud

The lidar point cloud is derived from a North Carolina Phase 3 lidar
mapping, tile `LA_37_20079303_20160228.las`.
The `points.las.7z` file was created from the original tile by cropping
it using `las2las` from libLAS:

    las2las points.las --output points_clip.las \
        --extent "2090835 730212 2092347 731322"

and compressed using `7zr`:

    7zr a points.las.7z points.las

Note that `7zr` from the `p7zip` package is in this case equivalent
with the `7z` tool from the `p7zip-full` package on Ubuntu.

### Orthophoto

The orthophoto was obtained from NC OneMap web service:

    http://services.nconemap.com/arcgis/services/Imagery/Orthoimagery_All/ImageServer/WMSServer

The ortophoto raster map in GRASS GIS was compressed using BZIP2:

    GRASS_COMPRESSOR=BZIP2 r.compress map=ortho

and exported in (native) GRASS GIS pack format:

    r.pack input=ortho output=ortho.grpack

### Zones

Manually selected and digitized polygons for zonal analysis were
exported from GRASS GIS in a (native) ASCII format using:

    v.out.ascii input=zones layer=-1 type=boundary,centroid \
        format=standard precision=2 output=zones.txt

Trailing spaces were removed using:

    sed -i 's/\s*$//g' zones.txt

The header was edited and cleaned up manually.

### Computational regions

The repository include two computational regions for GRASS GIS which can
be copied into GRASS GIS spatial database and used as *saved regions*.
The `study_region` file stores the extent of the study area and
the `study_region_real` files stores a very small extent meant for
testing the processing chain.

### 3D visualization

The `main_cat_3d.png` file is a manually created using GRASS GIS 3D view
(NVIZ). Theoretically, same image can be obtained using *m.nviz.image*
module.
