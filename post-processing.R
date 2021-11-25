fs::dir_copy("slides/", "_book/slides/", overwrite = TRUE)
fs::file_move("_book/slides/gsd-deming-slides.html", "_book/slides/index.html")
