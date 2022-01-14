library(magrittr)

"slides/gsd-deming-slides.Rmd" %>% rmarkdown::render() %>% browseURL()

# "slides/RinPharma2021KeavenAnderson.Rmd" %>% rmarkdown::render() %>% browseURL()

"vignettes/CureModelDesign.Rmd" %>% rmarkdown::render() %>% browseURL()

"vignettes/EXAMINEdesignupdatereport.Rmd" %>% rmarkdown::render() %>% browseURL()
