for (qmd in list.files(pattern = ".qmd")) {
  print(
    spelling::spell_check_files(
      qmd,
      ignore = scan("scripts/spell-ignore.txt", what = "complex", quiet = TRUE)
    )
  )
}

local({
  x <- readLines("scripts/spell-ignore.txt")
  x <- x[order(sapply(x, function(y) substr(y, 1, 1) %in% LETTERS), tolower(x))]
  writeLines(x, con = "scripts/spell-ignore.txt")
})
