.PHONY: data clean download info

# Boundary mode:
# - de_facto: Natural Earth's default country borders, based on control on the ground.
# - de_jure: Natural Earth point-of-view borders. By default, this uses the USA POV.
# - de_juro: backward-compatible alias for de_jure.
BOUNDARY_VIEW ?= de_facto

# Scale is used only for the default de_facto dataset.
# Natural Earth POV datasets are published as 10m datasets.
SCALE ?= 50m

# POV is used only for de_jure mode.
# Examples: usa, ukr, deu, fra, gbr, iso, rus.
POV ?= usa

# Lower precision and larger simplify tolerance produce smaller GeoJSON files.
COORDINATE_PRECISION ?= 4
SIMPLIFY_TOLERANCE ?= 0.01

DATA_DIR := data

NATURAL_EARTH_BASE_URL := https://naciscdn.org/naturalearth

# Default Natural Earth countries dataset.
COUNTRIES_DATASET := ne_$(SCALE)_admin_0_countries
COUNTRIES_URL := $(NATURAL_EARTH_BASE_URL)/$(SCALE)/cultural/$(COUNTRIES_DATASET).zip

# Natural Earth global point-of-view dataset.
POV_DATASET := ne_10m_admin_0_countries_$(POV)
POV_URL := $(NATURAL_EARTH_BASE_URL)/10m/cultural/$(POV_DATASET).zip

ifeq ($(BOUNDARY_VIEW),de_juro)
NORMALIZED_BOUNDARY_VIEW := de_jure
else
NORMALIZED_BOUNDARY_VIEW := $(BOUNDARY_VIEW)
endif

ifeq ($(NORMALIZED_BOUNDARY_VIEW),de_facto)
DATASET := $(COUNTRIES_DATASET)
SOURCE_URL := $(COUNTRIES_URL)
OUTPUT_FILE := $(DATA_DIR)/countries.geojson
OGR_SQL := SELECT admin as name, iso_a3 as "ISO3166-1-Alpha-3", iso_a2 as "ISO3166-1-Alpha-2" FROM $(COUNTRIES_DATASET)
else ifeq ($(NORMALIZED_BOUNDARY_VIEW),de_jure)
DATASET := $(POV_DATASET)
SOURCE_URL := $(POV_URL)
OUTPUT_FILE := $(DATA_DIR)/countries_de_jure_$(POV).geojson
OGR_SQL := SELECT admin as name, iso_a3 as "ISO3166-1-Alpha-3", iso_a2 as "ISO3166-1-Alpha-2" FROM $(POV_DATASET)
else
$(error Unsupported BOUNDARY_VIEW "$(BOUNDARY_VIEW)". Use "de_facto" or "de_jure")
endif

ZIP_FILE := $(DATASET).zip

info:
	@echo "BOUNDARY_VIEW=$(BOUNDARY_VIEW)"
	@echo "NORMALIZED_BOUNDARY_VIEW=$(NORMALIZED_BOUNDARY_VIEW)"
	@echo "SCALE=$(SCALE)"
	@echo "POV=$(POV)"
	@echo "COORDINATE_PRECISION=$(COORDINATE_PRECISION)"
	@echo "SIMPLIFY_TOLERANCE=$(SIMPLIFY_TOLERANCE)"
	@echo "DATASET=$(DATASET)"
	@echo "SOURCE_URL=$(SOURCE_URL)"
	@echo "OUTPUT_FILE=$(OUTPUT_FILE)"

clean:
	find . -maxdepth 1 -name "*.zip" -exec rm -f {} +
	rm -f data/countries.geojson data/countries.geojson.gz
	rm -f data/countries_de_jure_*.geojson data/countries_de_jure_*.geojson.gz

download:
	@if [ ! -f "$(ZIP_FILE)" ]; then \
		curl -L -o "$(ZIP_FILE)" "$(SOURCE_URL)"; \
	fi

data: download
	mkdir -p "$(DATA_DIR)"
	ogr2ogr -f GeoJSON \
		-makevalid \
		-simplify $(SIMPLIFY_TOLERANCE) \
		-lco COORDINATE_PRECISION=$(COORDINATE_PRECISION) \
		-sql '$(OGR_SQL)' \
		"$(OUTPUT_FILE)" \
		/vsizip/"$(ZIP_FILE)"
	tmp_file=$$(mktemp); \
	jq -c . "$(OUTPUT_FILE)" > "$$tmp_file"; \
	mv "$$tmp_file" "$(OUTPUT_FILE)"
	gzip -kf -9 "$(OUTPUT_FILE)"