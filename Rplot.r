require(data.table)
require(ggplot2)
require(here)
# analysis of the data for tredmill
# dir<-setwd('C:/Users/Windows/Desktop/test_tread/expinfo')
# files<-list.files(pattern='.csv')
pathFile<-here()
pathFile<-'C:/Users/Windows/Desktop/SyngapKO 9-19-19 shock/SyngapKO 9-19-19 shock teraterm'
data<-fread(paste(pathFile,'/expinfo/summary.csv', sep=''))# data
data<-data[,!1]


# not necessary the best way to modify
fit<-aov(fwdRun ~ habDay*Genotype + Error(sID/(habDay)), data)
summary(fit)

fit<-aov(bckRun ~ habDay*Genotype + Error(sID/(habDay)), data)
summary(fit)


cbPalette<-c('#4758A6','#BC0404','#A8ABD5','#DD9E89')

give.n <- function(x){
        return(c(y=0.1, label = length(x))) 
        # experiment with the multiplier to find the perfect position
        }

#xlabs <- paste(levels(data$group),"\n(n=",table(data$group),")",sep="")
# str(dd)
data<-melt(data, id=c('sID','habDay','Genotype'))
data$habDay<-as.factor(data$habDay)
data$Genotype<-factor(data$Genotype, levels = c('wt','het'))
data$variable<-factor(data$variable, levels = c('fwdRun','bckRun'))

# quartz(,1.853211, 2.935780)
windows(,3.9,5.2)
# ploting
  ggplot(data, aes(x=habDay, y=value/1000, color = Genotype, group = Genotype)) + # 
          #geom_point(size=2, alpha=0.3, position = position_jitterdodge(jitter.width = 0.5,
          #                                                         jitter.height = 0,
          #                                                     dodge.width = 0.6)) +
          facet_wrap(~ variable*Genotype, ncol = 6)+
          
          geom_bar(aes(fill=Genotype),
                   alpha=0.3,
                   stat="summary",
                   width=1,
                   fun.y =mean,
                   color="black",
                   position=position_dodge(01))+
          
          geom_line(aes(group=sID, color = Genotype), size=0.8, alpha=0.5 )+
          geom_point(size=2,
                     shape=21,
                     fill="grey90",
                     alpha=1, position = position_jitterdodge(jitter.width = 0,
                                                              jitter.height = 0,
                                                              dodge.width = 0)) +
          #stat_summary(fun.data = give.n,
          #             color="black",
          #             geom="text",
          #             size=4)+
          
          stat_summary(fun.y = mean,
                       fun.ymin = function(x) mean(x), 
                       fun.ymax = function(x) mean(x), 
                       geom = "pointrange",
                       linetype = 1) +
          stat_summary(fun.y = mean,
                       geom = "line", size = 1.25) +
          stat_summary(fun.ymin=function(x)(mean(x)-sd(x)/sqrt(length(x))), 
                       fun.ymax=function(x)(mean(x)+sd(x)/sqrt(length(x))),
                       geom="errorbar", width=0.05)+ #color="black"
          # annotate("text")+
          #geom_rangeframe(data=data.frame(y=c(0, 100)), aes(y)) + 
          #theme_bw() +
          #scale_y_continuous(limits = c(0, 100)) +
          #xlab("") +
          #scale_x_discrete(lables=xlabs,
          #                limits = c(1,12),
          #                breaks = 0:20 * 2)
          #                 )+
          xlab("habituation day")+
          ylab("Run (m)") +
          ggtitle("") +
          #scale_y_continuous(limits=c(0, 0.7),                           # Set y range
          #                   breaks=0:1000 * 0.2,
          #                   expand = c(0,0)) +                      # Set tick every 4
          #scale_x_discrete(labels=c("c\n1","c\n2","c\n3","c\n4"))+
          scale_fill_manual(values=cbPalette)+
          scale_colour_manual(values=cbPalette)+
          #theme_bw()+
          theme( #strip.text.x = element_blank(),
                  #strip.background = element_blank(),
                  strip.text.x = element_text(size = 14, colour = "black", angle = 0),
                  strip.background = element_rect(fill="grey85", colour="black"),
                  axis.line = element_line(color="black", size=0.5),
                  #axis.line.x = element_blank(),
                  axis.text = element_text(size=18, color = "black"),
                  axis.title = element_text(size = 18, color = "black"),
                  #axis.text.x = element_blank(),
                  axis.ticks.x = element_blank(),
                  #axis.title.x = element_text(margin=margin(0,0,0,0))
                  #axis.ticks.x = element_blank(),
                  axis.ticks = element_line(color="black", size=0.5),
                  panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  panel.border = element_blank(),
                  legend.position="NONE",
                  panel.background = element_blank())

# saving
savePlot(paste(pathFile,'/expinfo/summaryFig.pdf', sep=''), type = 'pdf')
dev.off()
