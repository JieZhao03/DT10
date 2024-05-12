
#================
# Load libraries
#================
library(ggplot2)


#=============================================================
# 2、Feature importance ranking of the decision tree model 
#=============================================================

# Load the trained learner
load("learner.Rdata")

# Obtain the feature importance ranking
RFimp <- data.frame(vip = learner$importance(),
                    variable = names(learner$importance()))
RFimp <- RFimp[order(RFimp$vip, decreasing = F),] 
RFimp$variable <- factor(RFimp$variable, levels = RFimp$variable)

ggplot(RFimp,aes(x = variable,y = vip, fill = variable)) + 
  geom_bar(stat = "identity") + coord_flip()
