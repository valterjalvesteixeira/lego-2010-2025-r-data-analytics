# 06 | BA2 - Associacao entre variacao da oferta e crescimento da receita
fin <- read.csv('dados/processados/lego_financas_2010_2025.csv')
tam <- read.csv('dados/processados/lego_evolucao_tamanhos.csv')
ba2 <- merge(fin,tam,by='ano',sort=TRUE)
ba2 <- ba2[order(ba2$ano),]
stopifnot(nrow(ba2)==16,identical(as.integer(ba2$ano),2010:2025))
ba2$crescimento_receita <- c(NA,diff(ba2$receita)/head(ba2$receita,-1)*100)
ba2$variacao_grandes <- c(NA,diff(ba2$pct_1000))
d <- subset(ba2,!is.na(crescimento_receita) & !is.na(variacao_grandes))
stopifnot(nrow(d)==15)
resultado <- cor.test(d$crescimento_receita,d$variacao_grandes,
                     method='spearman',exact=FALSE)
cat(sprintf('Spearman rho = %.4f; p = %.4f (n = %d)\n',
    unname(resultado$estimate),resultado$p.value,nrow(d)))
write.csv(ba2,'dados/processados/lego_analise_BA2.csv',row.names=FALSE)
write.csv(data.frame(metrica=c('rho_Spearman','valor_p','n'),
 valor=c(unname(resultado$estimate),resultado$p.value,nrow(d))),
 'dados/processados/lego_teste_correlacao.csv',row.names=FALSE)
png('resultados/graficos/06_correlacao_variacoes.png',width=1600,height=1000,res=150)
par(mar=c(5,6,4,2))
plot(d$variacao_grandes,d$crescimento_receita,pch=19,col='steelblue',cex=1.2,
     xlab='Variacao anual de referencias >=1000 pecas (pontos percentuais)',
     ylab='Crescimento anual das receitas (%)',
     main='LEGO: variacao da oferta vs crescimento de receita')
text(d$variacao_grandes,d$crescimento_receita,labels=d$ano,pos=3,cex=0.7)
abline(h=0,v=0,lty=2,col='grey60')
dev.off()
# Limite: correlacao nao demonstra causalidade, 15 observacoes,
# receitas anuais abrangem produtos de varios anos e segmentos.
