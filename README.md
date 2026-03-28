
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ggsegJulich

<!-- badges: start -->
<!-- badges: end -->

Contains data for ggseg for the Julich-Brain cytoarchitectonic atlas.

Amunts K et al. (2020) "Julich-Brain: A 3D probabilistic atlas of the
human brain's cytoarchitecture." Science, 369(6506):988-992.
[doi:10.1126/science.abb4588](https://doi.org/10.1126/science.abb4588)

## Installation

We recommend installing the ggseg-atlases through the ggseg
[r-universe](https://ggsegverse.r-universe.dev/ui#builds):

``` r
# Enable this universe
options(repos = c(
    ggsegverse = 'https://ggsegverse.r-universe.dev',
    CRAN = 'https://cloud.r-project.org'))

# Install some packages
install.packages('ggsegJulich')
```

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("ggsegverse/ggsegJulich")
```

## Source data files

The Julich-Brain atlas is available from the EBRAINS platform and
requires registration to download:

<https://ebrains.eu/service/human-brain-atlas>

After registering, download the Julich-Brain maximum probability map
(MPM) in MNI152 space (NIfTI format) and place it in `data-raw/`.

Reference: Amunts K et al. (2020) "Julich-Brain: A 3D probabilistic
atlas of the human brain's cytoarchitecture." *Science*,
369(6506):988-992.
doi:[10.1126/science.abb4588](https://doi.org/10.1126/science.abb4588)

Please note that the 'ggsegJulich' project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to
this project, you agree to abide by its terms.
