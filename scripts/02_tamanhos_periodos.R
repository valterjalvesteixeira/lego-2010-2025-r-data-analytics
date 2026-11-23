# 02 | Distribuicao por tamanho e periodos
sets <- read.csv('dados/processados/lego_sets_sem_bigbox.csv',stringsAsFactors=FALSE)
stopifnot(all(sets$ano %in% 2010:2025), all(sets$numero_pecas>0))
anos <- 2010:2025
resumo_ano <- do.call(rbind,lapply(anos,function(a) {
  d <- subset(sets,ano==a)
  stopifnot(nrow(d)>0)
  data.frame(ano=a,total_sets=nrow(d),mediana_pecas=median(d$numero_pecas),
             media_pecas=round(mean(d$numero_pecas),1),
             pct_1000=round(mean(d$numero_pecas>=1000)*100,2),
             pct_2000=round(mean(d$numero_pecas>=2000)*100,2),
             pct_3000=round(mean(d$numero_pecas>=3000)*100,2))
}))
write.csv(resumo_ano,'dados/processados/lego_evolucao_tamanhos.csv',row.names=FALSE)
# Escaloes disjuntos: nao confundir com os cortes cumulativos >=1000 etc.
sets$faixa_pecas <- cut(sets$numero_pecas,
    breaks=c(0,99,499,999,1999,2999,3999,4999,Inf),
    labels=c('1-99','100-499','500-999','1000-1999','2000-2999','3000-3999','4000-4999','5000+'),
    include.lowest=TRUE)
faixas <- as.data.frame(table(sets$ano,sets$faixa_pecas),stringsAsFactors=FALSE)
names(faixas) <- c('ano','faixa_pecas','total_sets')
faixas$ano <- as.integer(as.character(faixas$ano))
faixas$percentagem <- round(faixas$total_sets / ave(faixas$total_sets,faixas$ano,FUN=sum)*100,2)
medianas <- aggregate(numero_pecas ~ ano + faixa_pecas, data=sets,FUN=median)
names(medianas)[3] <- 'mediana_pecas'
faixas <- merge(faixas,medianas,by=c('ano','faixa_pecas'),all.x=TRUE,sort=FALSE)
faixas <- faixas[order(faixas$ano,faixas$faixa_pecas),]
write.csv(faixas,'dados/processados/lego_escaloes_2010_2025.csv',row.names=FALSE)
# 2010-2019: anterior; 2020-2021: fase inicial; 2022-2025: posterior
sets$periodo <- cut(sets$ano, breaks=c(2009,2019,2021,2025),
                    labels=c('2010-2019','2020-2021','2022-2025'))
periodos <- do.call(rbind,lapply(split(sets,sets$periodo),function(d) {
  data.frame(periodo=as.character(d$periodo[1]),total_sets=nrow(d),
             media_sets_ano=round(nrow(d)/length(unique(d$ano)),1),
             mediana_pecas=median(d$numero_pecas),
             pct_1000=round(mean(d$numero_pecas>=1000)*100,2),
             pct_2000=round(mean(d$numero_pecas>=2000)*100,2),
             pct_3000=round(mean(d$numero_pecas>=3000)*100,2))
}))
rownames(periodos) <- NULL
write.csv(periodos,'dados/processados/lego_comparacao_periodos.csv',row.names=FALSE)
# Graficos legiveis e independentes do painel Plots
png('resultados/graficos/02_evolucao_pct_grandes.png',width=1400,height=850,res=150)
plot(resumo_ano$ano,resumo_ano$pct_1000,type='b',pch=19,col='steelblue',lwd=2,
     xlab='Ano',ylab='Percentagem de referencias >=1000 pecas',
     main='LEGO: proporcao de referencias de maior dimensao',ylim=c(0,max(resumo_ano$pct_1000)+2))
abline(v=c(2019.5,2021.5),lty=3,col='grey70');grid()
dev.off()
png('resultados/graficos/02_mediana_pecas.png',width=1400,height=850,res=150)
plot(resumo_ano$ano,resumo_ano$mediana_pecas,type='b',pch=19,col='steelblue',lwd=2,
     xlab='Ano',ylab='Mediana de pecas por referencia',
     main='LEGO: evolucao da dimensao tipica dos conjuntos')
grid();dev.off()
cat('Resumo de periodos:\n');print(periodos)
