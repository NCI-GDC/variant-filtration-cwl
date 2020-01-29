GDC Variant Filtration CWL
---

The repository has only been tested on GDC data and in the particular environment GDC is running in. Some of the reference data required for the workflow production are hosted in [GDC reference files](https://gdc.cancer.gov/about-data/data-harmonization-and-generation/gdc-reference-files "GDC reference files"). For any questions related to GDC data, please contact the GDC Help Desk at support@nci-gdc.datacommons.io.

There are multiple workflows present in this repository:

* `gdc-variant-filtration.minimal.cwl` - minimal filters (e.g., MuTect2 and MuSE)
* `gdc-variant-filtration.with-fpfilter.cwl` - minimal + fpfilter (e.g., VarScan2)
* `gdc-variant-filtration.with-fpfilter.with-somaticscore.cwl` - minimal + fpfilter + somaticscore (e.g., SomaticSniper)
* `gdc-variant-filtration.pindel.cwl` - formatting of Pindel VCFs
