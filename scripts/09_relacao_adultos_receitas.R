
# PROJETO LEGO 2010-2025
# 09 - Relacao entre conjuntos 18+ e receitas

# Importar os dados

adultos <- read.csv(
  "dados/processados/lego_18mais_2020_2025.csv"
)

financas <- read.csv(
  "dados/processados/lego_financas_2010_2025.csv"
)

# Juntar os dados pelo ano

dados <- merge(
  adultos,
  financas[, c("ano", "receita")],
  by = "ano"
)

dados <- dados[order(dados$ano), ]

stopifnot(
  nrow(dados) == 6,
  identical(dados$ano, 2020:2025),
  all(dados$com_idade > 0)
)

# Percentagem 18+ entre os conjuntos com idade conhecida

dados$pct_18_calculada <- 100 *
  dados$adultos_18 / dados$com_idade

# Crescimento anual das receitas (%)

dados$crescimento_receita <- c(
  NA,
  100 * diff(dados$receita) /
    head(dados$receita, -1)
)

# Variacao anual da percentagem 18+ em pontos percentuais

dados$variacao_18_pp <- c(
  NA,
  diff(dados$pct_18_calculada)
)

# Guardar a tabela

write.csv(
  dados,
  "dados/processados/lego_adultos_receitas_2020_2025.csv",
  row.names = FALSE
)

# Mostrar os resultados

print(dados[, c(
  "ano",
  "adultos_18",
  "pct_18_calculada",
  "receita",
  "crescimento_receita",
  "variacao_18_pp"
)])


# Correlacao entre a percentagem 18+ e as receitas

correlacao_niveis <- cor.test(
  dados$pct_18_calculada,
  dados$receita,
  method = "spearman",
  exact = TRUE
)

cat("\nCorrelacao entre percentagem 18+ e receitas:\n")
print(correlacao_niveis)


# Correlacao entre as variacoes anuais

correlacao_variacoes <- cor.test(
  dados$variacao_18_pp[-1],
  dados$crescimento_receita[-1],
  method = "spearman",
  exact = TRUE
)

cat("\nCorrelacao entre variacoes anuais:\n")
print(correlacao_variacoes)


# Criar os graficos

png(
  "resultados/graficos/09_adultos_receitas.png",
  width = 1800,
  height = 1800,
  res = 150
)

par(mfrow = c(2, 1), mar = c(5, 6, 4, 3))

# Grafico 1: percentagem 18+ e receitas

plot(
  dados$pct_18_calculada,
  dados$receita,
  pch = 19,
  col = "steelblue",
  cex = 1.5,
  xlab = "Conjuntos 18+ entre os classificados (%)",
  ylab = "Receitas (milhoes DKK)",
  main = "LEGO - Produtos 18+ e receitas"
)

text(
  dados$pct_18_calculada,
  dados$receita,
  labels = dados$ano,
  pos = 3,
  cex = 0.8
)

grid()

# Grafico 2: variacoes de um ano para o seguinte

plot(
  dados$variacao_18_pp[-1],
  dados$crescimento_receita[-1],
  pch = 19,
  col = "darkgreen",
  cex = 1.5,
  xlab = "Variacao anual dos 18+ (pontos percentuais)",
  ylab = "Crescimento anual das receitas (%)",
  main = "LEGO - Comparacao das variacoes anuais"
)

text(
  dados$variacao_18_pp[-1],
  dados$crescimento_receita[-1],
  labels = dados$ano[-1],
  pos = 3,
  cex = 0.8
)

grid()

dev.off()

# Confirmar o grafico

file.exists(
  "resultados/graficos/09_adultos_receitas.png"
)
