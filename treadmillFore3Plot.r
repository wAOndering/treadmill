library(data.table)
library(ggplot2)

file<-'C:/Users/Windows/Desktop/treadmilldata/output/treadmillSummarye3.csv'
dt<-fread(file)

# Prepare the file to normalize the data with the amount of time that was spent during the phase
dt[, c('col1','col2','col3'):=tstrsplit(timeRec, " ", fixed=TRUE)]
dt[, c('col1','col2'):=tstrsplit(col3, ".", fixed=TRUE)]
dt[, c('col1','col2'):=tstrsplit(col3, ".", fixed=TRUE)]
dt[, c('col1','col2','col3'):=tstrsplit(col1, ":", fixed=TRUE)]


dt[, col1:=as.numeric(col1)]
dt[, col2:=as.numeric(col2)]
dt[, col3:=as.numeric(col3)]
dt[, phase:=as.numeric(phase)]

dt[, timeSec:=(col1*60*60+col2*60+col3)]
dt[, c('relativeFdist', 'relativeBdist'):= .(maxFdist/timeSec, maxBdist/timeSec)]

# remove inapropriate phase
unique(dt[, phase])
dt<-dt[!dt[, phase>=51 & phase<=53 | phase ==8]]
# value seems extremely high for this animal need to look at data
dt<-dt[!dt[, relativeFdist==max(dt[,relativeFdist])]]


cbPalette<-c('#4758A6','#BC0404','#A8ABD5','#DD9E89')
dt$Animal_geno<-factor(dt$Animal_geno, levels = c('wt','het'))
ggplot(dt, aes(x=Animal_geno, y=relativeBdist/(relativeFdist+relativeBdist), color = Animal_geno, group = Animal_geno)) + # 
        #geom_point(size=2, alpha=0.3, position = position_jitterdodge(jitter.width = 0.5,
        #                                                         jitter.height = 0,
        #                                                     dodge.width = 0.6)) +
        facet_wrap(~ phase, ncol = 7)+
        
        geom_bar(aes(fill=Animal_geno),
                 alpha=0.3,
                 stat="summary",
                 width=1,
                 fun.y =mean,
                 color="black",
                 position=position_dodge(01))+
        
        # geom_line(aes(group=Animal_id, color = Animal_geno), size=0.8, alpha=0.5 )+
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
        xlab("Phase")+
        ylab("percent bwd") +
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