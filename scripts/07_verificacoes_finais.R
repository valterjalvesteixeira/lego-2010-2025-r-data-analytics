
# PROJETO LEGO 2010-2025
# 07 - Verificacoes finais do projeto

# Funcao para verificar os resultados

verificar <- function(condicao, mensagem) {
  if (!isTRUE(condicao)) {
    stop(paste("ERRO:", mensagem), call. = FALSE)
  }
}

# 1. Verificar os ficheiros necessarios

ficheiros <- c(
  "dados/processados/lego_sets_sem_bigbox.csv",
  "dados/processados/lego_financas_2010_2025.csv",
  "dados/processados/lego_evolucao_tamanhos.csv",
  "dados/processados/lego_familias_detalhadas.csv",
  "dados/processados/lego_sets_com_idade.csv",
  "dados/processados/lego_resumo_18mais_ano.csv",
  "dados/processados/lego_18mais_2020_2025.csv",
  "dados/processados/lego_adultos_receitas_2020_2025.csv"
)

verificar(
  all(file.exists(ficheiros)),
  "Existem ficheiros de dados em falta."
)

# 2. Importar os dados

sets <- read.csv(ficheiros[1])
fin <- read.csv(ficheiros[2])
resumo <- read.csv(ficheiros[3])
sets_idade <- read.csv(ficheiros[5])
resumo_idade <- read.csv(ficheiros[6])
adultos <- read.csv(ficheiros[7])
dados09 <- read.csv(ficheiros[8])

# 3. Validar os conjuntos LEGO

verificar(
  !anyDuplicated(sets$numero_set),
  "Existem numeros de conjuntos duplicados."
)

verificar(
  !anyNA(sets[, c(
    "ano", "numero_set", "familia", "numero_pecas"
  )]),
  "Existem valores em falta nas colunas principais."
)

verificar(
  all(sets$numero_pecas > 0),
  "Existem conjuntos com numero de pecas invalido."
)

verificar(
  all(sets$ano >= 2010 & sets$ano <= 2025),
  "Existem anos fora do periodo analisado."
)

# 4. Validar os dados financeiros

verificar(
  nrow(fin) == 16,
  "O ficheiro financeiro nao tem 16 anos."
)

verificar(
  identical(as.integer(fin$ano), 2010:2025),
  "Os anos financeiros estao incorretos."
)

verificar(
  all(!is.na(fin$receita) & fin$receita > 0),
  "Existem receitas em falta ou invalidas."
)

# 5. Validar os resumos anuais

contagens <- as.integer(
  table(factor(sets$ano, levels = 2010:2025))
)

verificar(
  nrow(resumo) == 16,
  "O resumo anual nao tem 16 linhas."
)

verificar(
  identical(as.integer(resumo$ano), 2010:2025),
  "Os anos do resumo estao incorretos."
)

verificar(
  all(resumo$total_sets == contagens),
  "As contagens anuais nao coincidem."
)

# 6. Validar os dados etarios

verificar(
  nrow(sets_idade) == nrow(sets),
  "O cruzamento das idades alterou o total de conjuntos."
)

verificar(
  identical(
    as.character(sets_idade$numero_set),
    as.character(sets$numero_set)
  ),
  "Os identificadores dos conjuntos nao coincidem."
)

idade <- suppressWarnings(
  as.numeric(sets_idade$idade_minima)
)

verificar(
  all(is.na(idade) == is.na(sets_idade$idade_minima)),
  "Existem idades com formato invalido."
)

grupo_esperado <- ifelse(
  is.na(idade),
  "Sem informacao",
  ifelse(idade >= 18, "18+", "Menos de 18")
)

verificar(
  all(sets_idade$grupo_idade == grupo_esperado),
  "Existem classificacoes etarias incorretas."
)

# 7. Validar os indicadores 18+ por ano

anos <- 2010:2025

contagem_idade <- as.integer(
  table(factor(
    sets_idade$ano[!is.na(idade)],
    levels = anos
  ))
)

contagem_18 <- as.integer(
  table(factor(
    sets_idade$ano[!is.na(idade) & idade >= 18],
    levels = anos
  ))
)

verificar(
  identical(as.integer(resumo_idade$ano), anos),
  "Os anos do resumo etario estao incorretos."
)

verificar(
  all(resumo_idade$total == contagens),
  "Os totais anuais do resumo etario nao coincidem."
)

verificar(
  all(resumo_idade$com_idade == contagem_idade),
  "As contagens de idades conhecidas nao coincidem."
)

verificar(
  all(resumo_idade$adultos_18 == contagem_18),
  "As contagens de conjuntos 18+ nao coincidem."
)

# 8. Validar a analise 2020-2025

verificar(
  identical(as.integer(adultos$ano), 2020:2025),
  "O periodo da analise 18+ esta incorreto."
)

verificar(
  all(adultos$adultos_18 ==
        resumo_idade$adultos_18[11:16]),
  "Os valores 18+ de 2020-2025 nao coincidem."
)

# 9. Validar a relacao com as receitas

verificar(
  identical(as.integer(dados09$ano), 2020:2025),
  "Os anos da analise de receitas estao incorretos."
)

verificar(
  all(dados09$adultos_18 == adultos$adultos_18),
  "Os conjuntos 18+ nao coincidem na analise financeira."
)

verificar(
  all(dados09$receita ==
        fin$receita[match(dados09$ano, fin$ano)]),
  "As receitas da analise 09 nao coincidem."
)

# 10. Verificar os graficos principais

graficos <- c(
  "resultados/graficos/03_familias_comparacao.png",
  "resultados/graficos/05_arvore_simplificada.png",
  "resultados/graficos/08_evolucao_linhas_adultos.png",
  "resultados/graficos/08_evolucao_sets_18mais.png",
  "resultados/graficos/09_adultos_receitas.png"
)

verificar(
  all(file.exists(graficos)),
  "Existem graficos principais em falta."
)

verificar(
  all(file.info(graficos)$size > 0),
  "Existem graficos vazios."
)

# 11. Mostrar o resumo final

cat("\n====================================\n")
cat("VALIDACAO FINAL: OK\n")
cat("====================================\n")

cat("Referencias LEGO:", nrow(sets), "\n")
cat("Anos financeiros:", nrow(fin), "\n")

cat(
  "Conjuntos 18+:",
  sum(sets_idade$grupo_idade == "18+"),
  "\n"
)

cat(
  "Cobertura das idades:",
  round(100 * mean(!is.na(idade)), 2),
  "%\n"
)

cat(
  "Graficos principais:",
  sum(file.exists(graficos)),
  "de", length(graficos), "\n"
)

cat(
  "Total de graficos PNG:",
  length(list.files(
    "resultados/graficos",
    pattern = "\\.png$",
    ignore.case = TRUE
  )),
  "\n"
)

cat("\nNota: confirmar a origem e versao dos dados.\n")
cat("Projeto validado com sucesso.\n")
