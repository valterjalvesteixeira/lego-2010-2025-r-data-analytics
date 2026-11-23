# EXECUTAR APENAS SE NAO TIVER os dois ficheiros na pasta dados/originais.
# Fonte: Rebrickable. Os ficheiros evoluem; guardar data da descarga.
# Nao e chamado automaticamente pela rotina principal.
dir.create('dados/originais', recursive=TRUE, showWarnings=FALSE)
for (nome in c('sets','themes')) {
  destino <- file.path('dados','originais',paste0(nome,'.csv.gz'))
  if (!file.exists(destino)) {
    url <- paste0('https://cdn.rebrickable.com/media/downloads/', nome, '.csv.gz')
    download.file(url, destino, mode='wb')
    cat('Descarregado:', destino, '\n')
  } else {
    cat('Ja existente; nao substituir:', destino, '\n')
  }
}
cat('Data da verificacao:', format(Sys.time(), '%Y-%m-%d %H:%M'), '\n')
