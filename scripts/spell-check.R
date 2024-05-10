for (qmd in list.files(pattern = ".qmd")) {
  print(
    spelling::spell_check_files(
      qmd,
      ignore = scan("scripts/spell-ignore.txt", what = "complex", quiet = TRUE)
    )
  )
}
