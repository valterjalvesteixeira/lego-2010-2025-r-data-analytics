# 04 | Analise das receitas e dos lucros LEGO
# Valores em MILHOES DE COROAS DINAMARQUESAS (DKK), nao em euros.
# Valores da tabela inicial provenientes da sessao de trabalho anterior;
# confirmar com os PDF oficiais antes da entrega.
ficheiro <- 'dados/originais/lego_financas_2010_2025_conferencia.csv'
if (!file.exists(ficheiro)) stop('Falta a tabela financeira de referencia.')
fin <- read.csv(ficheiro)
fin <- fin[order(fin$ano),]
stopifnot(identical(as.integer(fin$ano),2010:2025),nrow(fin)==16,
          !anyNA(fin),!anyDuplicated(fin$ano))
write.csv(fin,'dados/processados/lego_financas_2010_2025.csv',row.names=FALSE)
fin$margem_liquida <- round(fin$lucro_liquido / fin$receita*100,2)
fin$crescimento_receita <- c(NA,round(diff(fin$receita)/head(fin$receita,-1)*100,2))
fin$crescimento_lucro <- c(NA,round(diff(fin$lucro_liquido)/head(fin$lucro_liquido,-1)*100,2))
write.csv(fin,'dados/processados/lego_indicadores_financeiros.csv',row.names=FALSE)
png('resultados/graficos/04_receitas.png',width=1500,height=850,res=150)
plot(fin$ano,fin$receita,type='b',pch=19,col='steelblue',lwd=2,
     xlab='Ano',ylab='Receita (milhoes DKK)',main='LEGO: receitas anuais 2010-2025')
grid();dev.off()
png('resultados/graficos/04_crescimento_receitas.png',width=1500,height=850,res=150)
d <- subset(fin,!is.na(crescimento_receita))
barplot(d$crescimento_receita,names.arg=d$ano,
        col=ifelse(d$crescimento_receita<0,'firebrick','steelblue'),
        las=2,main='LEGO: crescimento anual das receitas',ylab='Crescimento (%)',
        xlab='Ano',ylim=range(c(d$crescimento_receita,0))*1.15)
abline(h=0);dev.off()
cat('Indicadores financeiros processados (milhoes DKK).\n')
