#LEGO - Analise das linhas associadas ao publico adulto

sets <- read.csv(
  "dados/processados/lego_sets_sem_bigbox.csv",
  stringsAsFactors = FALSE
)

# Procurar linhas e produtos relevantes
padrao <- paste(
  c(
    "Botanical", "Bouquet", "Bonsai",
    "Orchid", "Succulent", "Flower",
    "Icons", "Creator Expert",
    "Architecture", "LEGO Art"
  ),
  collapse = "|"
)

texto <- paste(
  sets$familia,
  sets$tema,
  sets$titulo
)

candidatos <- sets[
  grepl(padrao, texto, ignore.case = TRUE),
]

# Quantidade por ano
cat("\nReferencias candidatas por ano:\n")

print(table(
  factor(candidatos$ano, levels = 2010:2025)
))

# Quantidade por familia
cat("\nFamilias identificadas:\n")

print(sort(
  table(candidatos$familia),
  decreasing = TRUE
))

# Guardar para posterior classificacao
write.csv(
  candidatos,
  "dados/processados/lego_candidatos_adultos.csv",
  row.names = FALSE
)

# 1. Classificar as principais linhas

candidatos$linha <- "Outros candidatos"

candidatos$linha[
  candidatos$familia == "Botanicals"
] <- "Botanicals"

candidatos$linha[
  candidatos$familia == "Icons"
] <- "Icons"

candidatos$linha[
  candidatos$familia == "Architecture"
] <- "Architecture"

candidatos$linha[
  candidatos$familia == "LEGO Art"
] <- "LEGO Art"

candidatos$linha[
  candidatos$tema == "Creator Expert"
] <- "Creator Expert"


# 2. Verificar as linhas identificadas

print(table(candidatos$linha))


# 3. Comparar a evolucao anual

tabela_linhas <- table(
  candidatos$ano,
  candidatos$linha
)

print(tabela_linhas)


# 4. Guardar resultados

write.csv(
  as.data.frame(tabela_linhas),
  "dados/processados/lego_evolucao_linhas_adultos.csv",
  row.names = FALSE
)

# 5. Preparar as principais linhas
anos <- 2010:2025

botanicals <- as.numeric(
  tabela_linhas[, "Botanicals"]
)

icons <- as.numeric(
  tabela_linhas[, "Icons"]
)

creator_expert <- as.numeric(
  tabela_linhas[, "Creator Expert"]
)

# 6. Criar a funcao do grafico
grafico_adultos <- function() {
  
  matplot(
    anos,
    cbind(botanicals, icons, creator_expert),
    type = "b",
    pch = c(16, 17, 15),
    lty = 1,
    lwd = 2,
    col = c("forestgreen", "steelblue", "darkorange"),
    xlab = "Ano",
    ylab = "Numero de referencias",
    main = "LEGO - Evolucao de linhas de produtos",
    xaxt = "n"
  )
  
  axis(1, at = anos, labels = anos, las = 2, cex.axis = 0.75)
  
  legend(
    "topleft",
    legend = c("Botanicals", "Icons", "Creator Expert"),
    col = c("forestgreen", "steelblue", "darkorange"),
    pch = c(16, 17, 15),
    lty = 1,
    bty = "n"
  )
  
  grid()
}

# 7. Mostrar no RStudio
grafico_adultos()

# 8. Guardar o grafico
png(
  "resultados/graficos/08_evolucao_linhas_adultos.png",
  width = 1800,
  height = 1100,
  res = 150
)

grafico_adultos()

dev.off()

# 9. Confirmar o ficheiro
file.exists(
  "resultados/graficos/08_evolucao_linhas_adultos.png"
)

# 10. Carregar o catalogo Brickset

data("legosets", package = "brickset")


# 11. Preparar o identificador dos conjuntos

legosets$numero_set <- paste0(
  legosets$number,
  "-",
  legosets$numberVariant
)


# 12. Cruzar os conjuntos com as idades

posicao <- match(
  sets$numero_set,
  legosets$numero_set
)

sets$idade_minima <- legosets$agerange_min[posicao]


# 13. Classificar os conjuntos

sets$grupo_idade <- ifelse(
  is.na(sets$idade_minima),
  "Sem informacao",
  ifelse(
    sets$idade_minima >= 18,
    "18+",
    "Menos de 18"
  )
)


# 14. Verificar os resultados

cat("\nClassificacao por idade:\n")
print(table(sets$grupo_idade))

cat("\nCobertura dos dados (%):\n")
print(round(
  100 * sum(!is.na(sets$idade_minima)) / nrow(sets),
  2
))


# 15. Guardar os dados enriquecidos

write.csv(
  sets,
  "dados/processados/lego_sets_com_idade.csv",
  row.names = FALSE
)

# 16. Preparar a classificacao por ano

anos <- 2010:2025

idade <- suppressWarnings(
  as.numeric(as.character(sets$idade_minima))
)

conhecida <- !is.na(idade)

resumo_idade <- data.frame(
  ano = anos,
  
  total = as.integer(
    table(factor(sets$ano, levels = anos))
  ),
  
  com_idade = as.integer(
    table(factor(sets$ano[conhecida], levels = anos))
  ),
  
  adultos_18 = as.integer(
    table(factor(
      sets$ano[conhecida & idade >= 18],
      levels = anos
    ))
  )
)

# 17. Calcular as percentagens

resumo_idade$pct_cobertura <- round(
  100 * resumo_idade$com_idade / resumo_idade$total,
  1
)

resumo_idade$pct_18 <- ifelse(
  resumo_idade$com_idade > 0,
  round(
    100 * resumo_idade$adultos_18 /
      resumo_idade$com_idade,
    1
  ),
  NA
)

# 18. Guardar os resultados anuais

write.csv(
  resumo_idade,
  "dados/processados/lego_resumo_18mais_ano.csv",
  row.names = FALSE
)

print(resumo_idade)

# 19. Criar grafico da evolucao 18+

png(
  "resultados/graficos/08_evolucao_sets_18mais.png",
  width = 1800,
  height = 1900,
  res = 150
)

par(
  mfrow = c(3, 1),
  mar = c(5, 5, 4, 2)
)

# Numero de conjuntos 18+

barplot(
  resumo_idade$adultos_18,
  names.arg = resumo_idade$ano,
  col = "steelblue",
  las = 2,
  main = "LEGO - Conjuntos classificados 18+",
  ylab = "Numero de conjuntos"
)

# Percentagem 18+ entre os conjuntos com idade

plot(
  resumo_idade$ano,
  resumo_idade$pct_18,
  type = "b",
  pch = 16,
  col = "darkgreen",
  xlab = "Ano",
  ylab = "Percentagem (%)",
  main = "Conjuntos 18+ entre os que tem idade conhecida"
)

grid()

# Cobertura dos dados etarios

plot(
  resumo_idade$ano,
  resumo_idade$pct_cobertura,
  type = "b",
  pch = 16,
  col = "darkorange",
  ylim = c(0, 100),
  xlab = "Ano",
  ylab = "Cobertura (%)",
  main = "Cobertura dos dados de idade"
)

grid()

dev.off()

# 20. Confirmar o grafico

file.exists(
  "resultados/graficos/08_evolucao_sets_18mais.png"
)
# Analise especifica da classificacao 18+

resumo_18_recente <- subset(
  resumo_idade,
  ano >= 2020 & ano <= 2025
)

print(resumo_18_recente)

write.csv(
  resumo_18_recente,
  "dados/processados/lego_18mais_2020_2025.csv",
  row.names = FALSE
)

