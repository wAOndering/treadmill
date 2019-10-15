require(data.table)
require(ggplot2)
require(plyr)


dir<-'/run/user/1000/gvfs/smb-share:server=ishtar,share=millerrumbaughlab/Vaissiere/HIGHSPEED/2019-09-09-EMXRUM2-shock wheel/teraterm/'

geno<-'expinfo/sIDgeno.csv'
geno<-paste(dir,geno,sep='')
geno<-fread(geno)

shock<-'output - preS10s - postS45s'
shock<-paste(dir,shock, sep='')
setwd(shock)
files<-list.files(pattern='.txt')

comboFiles<-list()
for(i in files){
	tmp<-fread(i)
	# tmp$fileName<-i
	comboFiles[[i]]<-tmp
	print(i)
	print(tmp)
}
comboFiles<-rbindlist(comboFiles)
comboFiles<-rename(comboFiles, c(animalID='sID'))
comboFiles<-merge(geno, comboFiles, by='sID')

fwrite(comboFiles, '/home/tom/Desktop/testFile.csv')
## ploting
# windows(,3.9,5.2)
X11()

cbPalette<-c('#4758A6','#BC0404','#A8ABD5','#DD9E89')

give.n <- function(x){
        return(c(y=0.1, label = length(x))) 
        # experiment with the multiplier to find the perfect position
        }

comboFiles[distanceWin < 0,]

# ploting
  ggplot(comboFiles, aes(x=shock, y=distanceWin, color = Genotype, group = Genotype)) + # 
          #geom_point(size=2, alpha=0.3, position = position_jitterdodge(jitter.width = 0.5,
          #                                                         jitter.height = 0,
          #                                                     dodge.width = 0.6)) +
          facet_wrap(~ shockWin)+
          
          # geom_bar(aes(fill=Genotype),
          #          alpha=0.3,
          #          stat="summary",
          #          width=1,
          #          fun.y =mean,
          #          color="black",
          #          position=position_dodge(01))+
          
          geom_line(aes(group=sID, color = Genotype), size=0.8, alpha=0.2 )+
          geom_point(size=2,
                     shape=21,
                     fill="grey90",
                     alph=0.2,
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
