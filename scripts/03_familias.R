
# PROJETO FINAL R - LEGO 2010-2025
# 03 - Analise e comparacao das familias LEGO


# 1. Importar os dados

sets <- read.csv(
  "dados/processados/lego_sets_sem_bigbox.csv",
  stringsAsFactors = FALSE
)


# 2. Verificar as colunas necessarias

colunas <- c("ano", "familia", "numero_pecas")

stopifnot(all(colunas %in% names(sets)))


# 3. Identificar os periodos

sets$periodo <- ifelse(
  sets$ano <= 2019,
  "2010-2019",
  ifelse(sets$ano >= 2022, "2022-2025", "Intermedio")
)


# 4. Selecionar os dois periodos

dados <- subset(
  sets,
  periodo != "Intermedio" &
    !is.na(familia) &
    familia != ""
)


# 5. Identificar conjuntos grandes

dados$grande <- as.integer(
  dados$numero_pecas >= 1000
)


# 6. Contar referencias por familia e periodo

resumo <- aggregate(
  cbind(
    total = rep(1, nrow(dados)),
    grandes = dados$grande
  ),
  by = list(
    familia = dados$familia,
    periodo = dados$periodo
  ),
  FUN = sum
)


# 7. Calcular a percentagem de conjuntos grandes

resumo$pct_grandes <- round(
  resumo$grandes / resumo$total * 100,
  2
)


# 8. Separar os dois periodos

antes <- subset(
  resumo,
  periodo == "2010-2019",
  select = c(familia, total, pct_grandes)
)

depois <- subset(
  resumo,
  periodo == "2022-2025",
  select = c(familia, total, pct_grandes)
)


# 9. Alterar os nomes das colunas

names(antes) <- c(
  "familia", "total_antes", "pct_antes"
)

names(depois) <- c(
  "familia", "total_depois", "pct_depois"
)


# 10. Juntar os dois periodos

comp <- merge(
  antes,
  depois,
  by = "familia"
)


# 11. Selecionar familias com pelo menos
# 30 referencias em cada periodo

comp <- subset(
  comp,
  total_antes >= 30 &
    total_depois >= 30
)


# 12. Calcular a variacao em pontos percentuais

comp$variacao_pp <- round(
  comp$pct_depois - comp$pct_antes,
  2
)


# 13. Ordenar pelo maior crescimento

comp <- comp[
  order(-comp$variacao_pp),
]

rownames(comp) <- NULL


# 14. Guardar a comparacao geral

dir.create(
  "dados/processados",
  recursive = TRUE,
  showWarnings = FALSE
)

write.csv(
  comp,
  "dados/processados/lego_crescimento_familias.csv",
  row.names = FALSE
)


# 15. Selecionar as cinco familias principais

foco <- c(
  "City",
  "Friends",
  "Icons",
  "Star Wars",
  "Technic"
)

dados_foco <- subset(
  dados,
  familia %in% foco
)


# 16. Calcular a mediana por familia e periodo

medianas <- aggregate(
  numero_pecas ~ familia + periodo,
  data = dados_foco,
  FUN = median
)

names(medianas)[3] <- "mediana_pecas"


# 17. Reunir os indicadores das cinco familias

resumo_foco <- merge(
  subset(
    resumo,
    familia %in% foco,
    select = c(familia, periodo, total, pct_grandes)
  ),
  medianas,
  by = c("familia", "periodo")
)

names(resumo_foco)[
  names(resumo_foco) == "total"
] <- "total_sets"

names(resumo_foco)[
  names(resumo_foco) == "pct_grandes"
] <- "pct_1000"


# 18. Criar todas as combinacoes
# de familia e periodo

grade <- expand.grid(
  familia = foco,
  periodo = c("2010-2019", "2022-2025"),
  stringsAsFactors = FALSE
)


# 19. Preservar as combinacoes sem referencias

resumo_foco <- merge(
  grade,
  resumo_foco,
  by = c("familia", "periodo"),
  all.x = TRUE
)


# 20. Substituir contagens em falta por zero
# As medianas e percentagens ficam NA

resumo_foco$total_sets[
  is.na(resumo_foco$total_sets)
] <- 0


# 21. Calcular a media anual de referencias

resumo_foco$media_sets_ano <- round(
  resumo_foco$total_sets /
    ifelse(
      resumo_foco$periodo == "2010-2019",
      10,
      4
    ),
  1
)


# 22. Organizar a tabela final

resumo_foco <- resumo_foco[, c(
  "familia",
  "periodo",
  "total_sets",
  "media_sets_ano",
  "mediana_pecas",
  "pct_1000"
)]

resumo_foco <- resumo_foco[
  order(resumo_foco$familia, resumo_foco$periodo),
]

rownames(resumo_foco) <- NULL


# 23. Guardar e apresentar o resumo

write.csv(
  resumo_foco,
  "dados/processados/lego_familias_detalhadas.csv",
  row.names = FALSE
)

cat("\nResumo das cinco familias LEGO:\n")

print(resumo_foco)


# 24. Selecionar as oito familias
# com maior aumento de conjuntos grandes

melhores <- head(
  subset(comp, variacao_pp > 0),
  8
)

if (nrow(melhores) == 0) {
  stop("Nao existem familias com variacao positiva.")
}


# 25. Preparar os dados do grafico

valores <- rbind(
  "2010-2019" = melhores$pct_antes,
  "2022-2025" = melhores$pct_depois
)

colnames(valores) <- melhores$familia


# 26. Simplificar nomes longos

colnames(valores) <- sub(
  "LEGO Ideas and CUUSOO",
  "LEGO Ideas",
  colnames(valores),
  fixed = TRUE
)


# 27. Colocar o maior crescimento no topo

valores <- valores[
  ,
  ncol(valores):1,
  drop = FALSE
]


# 28. Criar a pasta dos graficos

dir.create(
  "resultados/graficos",
  recursive = TRUE,
  showWarnings = FALSE
)


# 29. Guardar o grafico em PNG

png(
  "resultados/graficos/03_familias_comparacao.png",
  width = 1800,
  height = 1100,
  res = 150
)

par(
  mar = c(5, 14, 6, 4)
)


# 30. Criar as barras horizontais

posicoes <- barplot(
  valores,
  beside = TRUE,
  horiz = TRUE,
  col = c("grey65", "steelblue"),
  las = 1,
  cex.names = 0.85,
  xlim = c(0, max(valores) * 1.25),
  main = "LEGO - Evolucao dos Conjuntos Grandes",
  xlab = "Conjuntos com 1000 ou mais pecas (%)"
)


# 31. Colocar os valores junto das barras

text(
  x = as.vector(valores) + max(valores) * 0.02,
  y = as.vector(posicoes),
  labels = paste0(
    format(
      round(as.vector(valores), 1),
      decimal.mark = ",",
      trim = TRUE
    ),
    "%"
  ),
  pos = 4,
  cex = 0.65
)


# 32. Colocar a legenda fora das barras

mtext(
  "Cinzento: 2010-2019   |   Azul: 2022-2025",
  side = 3,
  line = 0.5,
  cex = 0.85
)


# 33. Terminar e guardar o grafico

dev.off()


# 34. Confirmar os ficheiros

cat("\nGrafico criado:\n")

print(
  file.exists(
    "resultados/graficos/03_familias_comparacao.png"
  )
)

cat("\nData de atualizacao:\n")

print(
  file.info(
    "resultados/graficos/03_familias_comparacao.png"
  )$mtime
)

cat("\nAnalise das familias concluida.\n")
