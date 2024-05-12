
#================
# Load libraries
#================
library(rpart.plot)


#=============================================================
# 3、Visualize the decision-making route 
#=============================================================

# Load the trained learner
load("learner.Rdata")
learner$train(task_train)$model %>% rpart.plot(cex = 0.4)
