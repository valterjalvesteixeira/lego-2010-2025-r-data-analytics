
# PROJETO LEGO 2010-2025
# Execucao completa das analises

# Confirmar que estamos na pasta do projeto

if (!file.exists("Projeto_LEGO_2010_2025.Rproj")) {
  stop("Abre primeiro o projeto no RStudio.")
}

# Criar as pastas necessarias

dir.create(
  "dados/processados",
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  "resultados/graficos",
  recursive = TRUE,
  showWarnings = FALSE
)

# Lista dos scripts pela ordem de execucao

scripts <- c(
  "01_preparacao_conjuntos.R",
  "02_tamanhos_periodos.R",
  "03_familias.R",
  "04_financas_BI.R",
  "05_arvore_decisao_BA1.R",
  "06_correlacao_BA2.R",
  "08_analise_segmento_adulto.R",
  "09_relacao_adultos_receitas.R",
  "07_verificacoes_finais.R"
)

# Verificar se existem todos os scripts

ficheiros <- file.path("scripts", scripts)

if (!all(file.exists(ficheiros))) {
  stop(
    "Faltam ficheiros: ",
    paste(
      ficheiros[!file.exists(ficheiros)],
      collapse = ", "
    )
  )
}

# Executar as analises

for (script in scripts) {
  
  cat(
    "\n======= A executar:",
    script,
    "=======\n"
  )
  
  source(
    file.path("scripts", script),
    encoding = "UTF-8",
    local = TRUE
  )
}

# Confirmar os novos resultados

graficos <- c(
  "resultados/graficos/03_familias_comparacao.png",
  "resultados/graficos/05_arvore_simplificada.png",
  "resultados/graficos/08_evolucao_linhas_adultos.png",
  "resultados/graficos/08_evolucao_sets_18mais.png",
  "resultados/graficos/09_adultos_receitas.png"
)

if (!all(file.exists(graficos))) {
  warning("Existem graficos esperados que nao foram encontrados.")
}

cat("\n====================================\n")
cat("EXECUCAO CONCLUIDA\n")
cat("Scripts executados:", length(scripts), "\n")
cat("Graficos verificados:", sum(file.exists(graficos)),
    "de", length(graficos), "\n")
cat("====================================\n")

