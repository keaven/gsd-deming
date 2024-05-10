# Group Sequential Design Under Non-Proportional Hazard

This is the code and text behind
[Group Sequential Design Under Non-Proportional Hazards](https://keaven.github.io/gsd-deming/).

Course material presented at the
[77th Annual Deming Conference on Applied Statistics](https://demingconference.org/programs/2021-program/)
in December 2021.

## Install dependencies

To build the book, first install Quarto.

Then, install the R packages used by the book with:

```r
# install.packages("remotes")
remotes::install_deps()
```

## Build the book

In RStudio IDE, press Cmd/Ctrl + Shift + B. Or run:

```r
quarto::quarto_render()
```
