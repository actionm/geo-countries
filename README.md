<a className="gh-badge" href="https://datahub.io/core/geo-countries"><img src="https://badgen.net/badge/icon/View%20on%20datahub.io/orange?icon=https://datahub.io/datahub-cube-badge-icon.svg&label&scale=1.25" alt="badge" /></a>

## Description

Geodata [data package][datapackage] providing GeoJSON polygons for all the world's countries.
Perfect for use in apps and visualizations.

## Data

The data comes from [Natural Earth][naturalearth], a community effort to make visually pleasing, well-crafted maps with cartography or GIS software at small scale.

This package provides two generated outputs:

- `data/countries.geojson` - default Natural Earth country boundaries based on de facto control on the ground.
- `data/countries_de_jure_usa.geojson` - Natural Earth global point-of-view boundaries using the USA POV, intended for an internationally recognised / de jure-style view of disputed borders.

Compressed `.gz` files are generated next to each GeoJSON file.

More info about countries can be obtained from datapackage https://github.com/datasets/country-codes by a join on field `ISO3166-1-Alpha-3`.

[naturalearth]: https://www.naturalearthdata.com/
[datapackage]: https://datapackage.org/standard/data-package/

## Preparation

To run the script and update the data:

### Prerequisites

1. Install required tools:
   - [GDAL](https://gdal.org/en/latest/download.html) - for geographic data processing (`ogr2ogr`)
   - [jq](https://jqlang.github.io/jq/) - for compacting generated GeoJSON

2. Verify installation:

   ```bash
   ogr2ogr --version
   jq --version
   ```

### Data Processing

The project uses `ogr2ogr` to convert Natural Earth's country boundaries from Shapefile to GeoJSON format, with the following features:

- Geometry validation enabled (`-makevalid`):
  - Fixes self-intersecting polygons
  - Corrects ring orientation
  - Removes duplicate vertices
  - Ensures geometric validity for better compatibility with GIS tools
- Optional geometry simplification through `SIMPLIFY_TOLERANCE`
- Coordinate precision control through `COORDINATE_PRECISION`
- Compact JSON output through `jq -c`
- Gzip-compressed output through `gzip -9`
- Selected fields:
  - `name`: Common name of the country from the Natural Earth `admin` field
  - `ISO3166-1-Alpha-2`: Two-letter ISO country code from the `iso_a2` field
  - `ISO3166-1-Alpha-3`: Three-letter ISO country code from the `iso_a3` field

To process the default de facto data:

```bash
make data
```

This will:

1. Download the Natural Earth countries dataset.
2. Convert it to GeoJSON format.
3. Save the result in `data/countries.geojson`.
4. Save the compressed result in `data/countries.geojson.gz`.

To process the de jure / USA POV data:

```bash
make data BOUNDARY_VIEW=de_jure POV=usa
```

This will:

1. Download the Natural Earth USA point-of-view countries dataset.
2. Convert it to GeoJSON format.
3. Save the result in `data/countries_de_jure_usa.geojson`.
4. Save the compressed result in `data/countries_de_jure_usa.geojson.gz`.

### Makefile Options

| Option | Default | Description |
| --- | --- | --- |
| `BOUNDARY_VIEW` | `de_facto` | Boundary mode. Use `de_facto` for Natural Earth's default country boundaries or `de_jure` for Natural Earth point-of-view boundaries. |
| `SCALE` | `50m` | Natural Earth scale for `de_facto` output. Supported values are typically `10m`, `50m`, and `110m`. |
| `POV` | `usa` | Natural Earth point-of-view dataset used for `de_jure` output. Examples: `usa`, `ukr`, `deu`, `fra`, `gbr`, `iso`, `rus`. |
| `COORDINATE_PRECISION` | `4` | Number of decimal places kept in output coordinates. Lower values reduce file size. |
| `SIMPLIFY_TOLERANCE` | `0.01` | Geometry simplification tolerance. Larger values reduce file size but also reduce border detail. |

Examples:

```bash
make data
make data BOUNDARY_VIEW=de_jure
make data BOUNDARY_VIEW=de_jure POV=usa
make data SCALE=110m COORDINATE_PRECISION=3
make data BOUNDARY_VIEW=de_jure SIMPLIFY_TOLERANCE=0.03 COORDINATE_PRECISION=3
```

## License

All data is licensed under the [Open Data Commons Public Domain Dedication and License][pddl].

Note that the original data from [Natural Earth][naturalearth] is public domain. While no credit is
formally required, a link back or credit to [Natural Earth][naturalearth], [Lexman][lexman], and the [Open Knowledge Foundation][okfn] is much appreciated.

All source code is licenced under the [MIT licence][mit].

[mit]: https://opensource.org/licenses/MIT
[naturalearth]: https://www.naturalearthdata.com/
[pddl]: https://opendatacommons.org/licenses/pddl/1.0/
[lexman]: https://github.com/lexman
[okfn]: https://okfn.org/