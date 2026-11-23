# 05 | BA1 - Arvore de decisao (apenas ano e familia)
# Modelo exploratorio de classificacao >=1000 pecas. Sem data leakage:
# nunca utilizar numero_pecas para prever a classe derivada desse numero.
if (!requireNamespace('rpart',quietly=TRUE)) {
  stop('Falta o pacote rpart. Instalar uma vez no RStudio: install.packages("rpart")')
}
dados <- read.csv('dados/processados/lego_sets_sem_bigbox.csv',stringsAsFactors=FALSE)
dados$classe <- factor(ifelse(dados$numero_pecas>=1000,'grande','pequeno'),
                       levels=c('pequeno','grande'))
# Funcoes auxiliares, sem depender do Environment da consola.
preparar_familias <- function(treino, novos) {
  freq <- table(treino$familia)
  frequentes <- names(freq[freq>=50])
  niveis <- unique(c(sort(frequentes),'Outras'))
  agrupar <- function(d) {
    d$familia_grupo <- factor(ifelse(d$familia %in% frequentes,d$familia,'Outras'),
                             levels=niveis)
    d
  }
  list(treino=agrupar(treino), novos=agrupar(novos))
}
metricas <- function(real,prev) {
  cm <- table(Real=factor(real,levels=c('pequeno','grande')),
              Previsto=factor(prev,levels=c('pequeno','grande')))
  VP <- cm['grande','grande']; VN <- cm['pequeno','pequeno']
  FP <- cm['pequeno','grande']; FN <- cm['grande','pequeno']
  prec <- if(VP+FP==0) 0 else VP/(VP+FP)
  rec <- if(VP+FN==0) 0 else VP/(VP+FN)
  esp <- if(VN+FP==0) 0 else VN/(VN+FP)
  f1 <- if(prec+rec==0) 0 else 2*prec*rec/(prec+rec)
  list(matriz=cm,indicadores=data.frame(accuracy=round(100*(VP+VN)/sum(cm),2),
    precision=round(100*prec,2),recall=round(100*rec,2),
    f1_score=round(100*f1,2),balanced_accuracy=round(50*(rec+esp),2)))
}
treinar <- function(treino,prior_grande) {
  rpart::rpart(classe ~ ano + familia_grupo,data=treino,method='class',
    parms=list(prior=c(1-prior_grande,prior_grande)),
    control=rpart::rpart.control(cp=0.005,minsplit=40,maxdepth=6))
}
# Validacao interna: treino 2010-2019; validacao 2020-2022.
treino_i <- subset(dados,ano<=2019)
validacao <- subset(dados,ano>=2020 & ano<=2022)
p <- preparar_familias(treino_i,validacao)
treino_i <- p$treino;validacao <- p$novos
priors <- c(0.5,0.4,0.3,0.2,0.1)
resumos <- lapply(priors,function(pg) {
  m <- treinar(treino_i,pg)
  prev <- predict(m,newdata=validacao,type='class')
  met <- metricas(validacao$classe,prev)
  data.frame(prior_grande=pg,met$indicadores)
})
comparacao <- do.call(rbind,resumos)
# Escolher primeiro maior F1 (desempate pela ordem predefinida)
prior_escolhido <- comparacao$prior_grande[which.max(comparacao$f1_score)]
write.csv(comparacao,'dados/processados/lego_validacao_modelos.csv',row.names=FALSE)
cat('Prior escolhido na validacao:',prior_escolhido,'\n');print(comparacao)
# Ajustar em 2010-2022, avaliar descritivamente em 2023-2025.
# O conjunto de teste ja foi consultado em trabalhos anteriores;


treino <- subset(dados,ano<=2022)
teste <- subset(dados,ano>=2023)
p <- preparar_familias(treino,teste)
treino <- p$treino;teste <- p$novos
modelo <- treinar(treino,prior_escolhido)
previsao <- predict(modelo,newdata=teste,type='class')
res <- metricas(teste$classe,previsao)
cat('Matriz de confusao no teste exploratorio:\n');print(res$matriz)
cat('Metricas no teste exploratorio:\n');print(res$indicadores)
write.csv(res$indicadores,'dados/processados/lego_resultado_modelo_final.csv',row.names=FALSE)
write.csv(as.data.frame.matrix(res$matriz),'dados/processados/lego_matriz_confusao.csv')
saveRDS(modelo,'dados/processados/lego_modelo_arvore.rds')

# Imagem de metricas com etiquetas curtas
v <- as.numeric(res$indicadores[1,c('accuracy','precision','recall','f1_score','balanced_accuracy')])
names(v) <- c('Accuracy','Precision','Recall','F1','Balanced acc.')
png('resultados/graficos/05_metricas_arvore.png',width=1400,height=900,res=150)
par(mar=c(8,5,4,2))
barplot(v,ylim=c(0,100),col='steelblue',las=2,
        main='LEGO: desempenho da arvore de decisao',ylab='Percentagem (%)')
dev.off()
# Grafico simplificado opcional se o pacote estiver instalado.

if (requireNamespace("rpart.plot", quietly = TRUE)) {
  
  png(
    "resultados/graficos/05_arvore_simplificada.png",
    width = 2200,
    height = 1400,
    res = 160
  )
  
  rpart.plot::rpart.plot(
    modelo,
    type = 2,
    extra = 104,
    under = TRUE,
    fallen.leaves = TRUE,
    cex = 0.85,
    faclen = 0,
    varlen = 0,
    box.palette = "Blues",
    shadow.col = "gray85",
    nn = TRUE,
    branch.lty = 1,
    branch = 0.35,
    roundint = FALSE,
    main = "Arvore de decisao - previsao de conjuntos grandes LEGO"
  )
  
  dev.off()
  
} else {
  message("Pacote 'rpart.plot' nao esta instalado. Grafico da arvore nao foi criado.")
}
