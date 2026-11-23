# 01 | Limpeza e enriquecimento dos conjuntos LEGO, 2010-2025
# Fonte principal: sets.csv.gz e themes.csv.gz do Rebrickable.
# A categoria "conjuntos analisaveis" e um filtro metodologico, nao uma
# certificacao de que cada referencia seja um produto de construcao.
origem_sets <- 'dados/originais/sets.csv.gz'
origem_temas <- 'dados/originais/themes.csv.gz'
if (!file.exists(origem_sets) || !file.exists(origem_temas)) {
  stop('Faltam sets.csv.gz e/ou themes.csv.gz em dados/originais. ',
       'Copiar da pen antiga ou executar manualmente scripts/00_obter_dados_rebrickable.R')
}
dir.create('dados/processados', recursive=TRUE, showWarnings=FALSE)
sets_raw <- read.csv(gzfile(origem_sets), stringsAsFactors=FALSE)
themes <- read.csv(gzfile(origem_temas), stringsAsFactors=FALSE)
stopifnot(all(c('year','set_num','name','theme_id','num_parts') %in% names(sets_raw)))
stopifnot(all(c('id','name','parent_id') %in% names(themes)))
lego_base <- subset(sets_raw, year >= 2010 & year <= 2025)
stopifnot(!anyDuplicated(lego_base$set_num))
# Encontrar a familia raiz percorrendo a hierarquia de temas.
obter_familia <- function(id) {
  atual <- id
  for (passo in seq_len(30)) {
    pos <- match(atual, themes$id)
    if (is.na(pos)) return('Nao classificada')
    pai <- themes$parent_id[pos]
    if (is.na(pai)) return(themes$name[pos])
    atual <- pai
  }
  'Nao classificada'
}
# Calcular a familia uma vez por theme_id, evitando percursos redundantes.
ids <- unique(lego_base$theme_id)
familias_map <- setNames(vapply(ids, obter_familia, character(1)), as.character(ids))
lego_base$familia <- unname(familias_map[as.character(lego_base$theme_id)])
lego_base$familia[is.na(lego_base$familia)] <- 'Nao classificada'
lego_base$tema <- themes$name[match(lego_base$theme_id, themes$id)]
lego_base$tema[is.na(lego_base$tema)] <- 'Tema desconhecido'
lego_base$com_pecas <- !is.na(lego_base$num_parts) & lego_base$num_parts > 0
# Auditoria antes de qualquer exclusao
resumo_qualidade <- aggregate(
  cbind(referencias=rep(1L,nrow(lego_base)), com_pecas=as.integer(lego_base$com_pecas)),
  by=list(familia=lego_base$familia), FUN=sum
)
resumo_qualidade$cobertura_pct <- round(100 * resumo_qualidade$com_pecas / resumo_qualidade$referencias,1)
resumo_qualidade <- resumo_qualidade[order(-resumo_qualidade$referencias), ]
write.csv(resumo_qualidade,'dados/processados/lego_auditoria_familias.csv',row.names=FALSE)
# Filtro documentado; conservar originais para permitir auditoria.
excluir_familias <- c('Gear','Books','Collectible Minifigures')
filtrados <- subset(lego_base, com_pecas & !(familia %in% excluir_familias))
filtrados <- filtrados[,c('year','set_num','name','theme_id','tema','familia','num_parts')]
names(filtrados) <- c('ano','numero_set','titulo','id_tema','tema','familia','numero_pecas')
filtrados <- filtrados[order(filtrados$ano,filtrados$numero_set),]
rownames(filtrados) <- NULL
stopifnot(all(filtrados$numero_pecas > 0), !anyDuplicated(filtrados$numero_set))
write.csv(filtrados,'dados/processados/lego_sets_construcao.csv',row.names=FALSE)
# BIGBOX-1: referencia especial, excluida apenas na versao analitica.
analiticos <- subset(filtrados, numero_set != 'BIGBOX-1')
write.csv(analiticos,'dados/processados/lego_sets_sem_bigbox.csv',row.names=FALSE)
cat('Total 2010-2025:',nrow(lego_base),'\n')
cat('Com filtro de familia e pecas:',nrow(filtrados),'\n')
cat('Analiticos sem BIGBOX-1:',nrow(analiticos),'\n')
cat('Nota: dados Rebrickable dependem da data de descarga.\n')
