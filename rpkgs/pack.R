library(pkglite)

# 1. These versions were used at the point of packing

# https://github.com/Merck/gsDesign2/tree/371ac84480ceb38b6e99c3b4b4ad803fa657810e
# https://github.com/Merck/simtrial/tree/b513e32cbc71ff184e94de4d7d3503fe454ec236
# https://github.com/Merck/gsdmvn/tree/af34897bb307873b0a23145911c9c89d6d5f31c1
# https://github.com/dominicmagirr/modestWLRT/tree/803453e5d29dc332e9c8b4d339f167ef73dc8b22

# 2. Pack

"rpkgs/gsDesign2/" %>%
  collate(file_default()) %>%
  pack(output = "rpkgs/gsDesign2.txt")

"rpkgs/simtrial/" %>%
  collate(file_default()) %>%
  pack(output = "rpkgs/simtrial.txt")

"rpkgs/gsdmvn/" %>%
  collate(file_default()) %>%
  pack(output = "rpkgs/gsdmvn.txt")

"rpkgs/modestWLRT/" %>%
  collate(file_default()) %>%
  pack(output = "rpkgs/modestWLRT.txt")

# 3. Edit the `DESCRIPTION` files and remove the `Remotes` field
