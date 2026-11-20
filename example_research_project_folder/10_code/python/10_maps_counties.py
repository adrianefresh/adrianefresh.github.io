"""
10_maps_counties.py  --  build county boundaries for Mississippi and Tennessee

    Margins of Incarceration

The NHGIS download in 10_source_data/50_nhgis/shapefiles has 1980 *county
subdivision* boundaries (minor civil divisions, "MCD"), not county boundaries.
Every subdivision carries its state and county FIPS codes, so we can rebuild
counties by dissolving (merging) the subdivisions that share a county code.

Input   10_source_data/50_nhgis/shapefiles/nhgis0048_shape/.../US_mcd_1980.shp
Output  _claude/30_intermediate_data/60_maps/10_maps_counties.gpkg
            layer "counties"  one polygon per county, with GISJOIN
            layer "states"    one polygon per state

Run from anywhere:   python 10_maps_counties.py
"""

import geopandas as gpd
from pathlib import Path

# ---------------------------------------------------------------------------
# paths
# ---------------------------------------------------------------------------

PROJECT = Path("/Users/vesper/Documents/Projects/Margins_Incarceration")

SHAPE_IN = (
    PROJECT
    / "10_source_data"
    / "50_nhgis"
    / "shapefiles"
    / "nhgis0048_shape"
    / "nhgis0048_shapefile_tl2000_us_cty_sub_1980"
    / "US_mcd_1980.shp"
)

OUT_DIR = PROJECT / "_claude" / "30_intermediate_data" / "60_maps"
OUT_DIR.mkdir(parents=True, exist_ok=True)
GPKG_OUT = OUT_DIR / "10_maps_counties.gpkg"


# states we want, as 1980 FIPS codes (strings, because the shapefile stores them as text)
STATES = {"28": "MS", "47": "TN"}


# ---------------------------------------------------------------------------
# read only the subdivisions in our two states
# ---------------------------------------------------------------------------

# The national file is 320 MB. The `where` clause is passed to the file reader
# so that only rows for Mississippi and Tennessee are loaded into memory.
where = "STATE80 IN ('28', '47')"
mcd = gpd.read_file(SHAPE_IN, where=where)

print(f"read {len(mcd):,} county subdivisions")
print(mcd[["STATE80", "COUNTY80", "NAME", "GISJOIN"]].head())
print("coordinate system:", mcd.crs.name)


# ---------------------------------------------------------------------------
# dissolve subdivisions into counties
# ---------------------------------------------------------------------------

# NHGIS county GISJOIN codes look like G2800010  (G + state + 0 + county + 0).
# The subdivision GISJOIN is the county code with the subdivision appended,
# so the first 8 characters identify the county.
mcd["gisjoin"] = mcd["GISJOIN"].str[:8]
mcd["state_fips"] = mcd["STATE80"]
mcd["county_fips"] = mcd["COUNTY80"]
mcd["state_abbr"] = mcd["STATE80"].map(STATES)

# dissolve = union of all polygons that share the key
counties = mcd.dissolve(
    by="gisjoin",
    as_index=False,
    aggfunc={"state_fips": "first", "county_fips": "first", "state_abbr": "first"},
)

# a five-digit state+county FIPS, matching state_county_fips in the Stata data
counties["state_county_fips"] = counties["state_fips"] + counties["county_fips"]

# keep the columns we need, in a tidy order
counties = counties[
    [
        "gisjoin",
        "state_county_fips",
        "state_abbr",
        "state_fips",
        "county_fips",
        "geometry",
    ]
]

print(f"\n{len(counties)} counties after dissolve")
print(counties["state_abbr"].value_counts())


# ---------------------------------------------------------------------------
# state outlines (for drawing borders on top of the county maps)
# ---------------------------------------------------------------------------

states = counties.dissolve(by="state_abbr", as_index=False)
states = states[["state_abbr", "geometry"]]


# ---------------------------------------------------------------------------
# save
# ---------------------------------------------------------------------------

# A GeoPackage holds several layers in one file. Delete any old file first so
# that re-running the script does not append duplicate layers.
if GPKG_OUT.exists():
    GPKG_OUT.unlink()

counties.to_file(GPKG_OUT, layer="counties", driver="GPKG")
states.to_file(GPKG_OUT, layer="states", driver="GPKG")

print(f"\nsaved {GPKG_OUT}")
