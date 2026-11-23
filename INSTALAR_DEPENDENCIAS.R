# Install only missing R packages. Run manually once.
pacotes <- c("rpart", "rpart.plot", "brickset")
instalados <- vapply(pacotes, requireNamespace, logical(1), quietly = TRUE)
if (any(!instalados)) {
  install.packages(pacotes[!instalados])
}
cat("Required packages are available.\n")
cat("brickset version:", as.character(packageVersion("brickset")), "\n")
