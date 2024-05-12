
#================
# Load libraries
#================
library(mlr3)
library(mlr3verse)
library(parallel)


#=============================================================
# 1、Train and test the decision tree model 
#=============================================================

# Load the real-world dataset to develop the decision tree model 
input_data <- read.csv("input_data.csv")
input_data <- data.frame(lapply(input_data, factor))

# Setting a seed to create reproducible results
set.seed(4038) 

# Create a classifier task    
task <- as_task_classif(input_data, target = "DCB", positive = "DCB") 

# Split the data into train and test sets
split <- partition(task, ratio = 0.8, stratify = T) 
train_idx <- split$train
test_idx <- split$test

task_train <- task$clone()$filter(train_idx)
task_test <- task$clone()$filter(test_idx)

# Create a decision tree learner 
learner = lrn("classif.rpart", predict_type = "prob")

# Tune the parameters for the "auc" using a grid search in bootstrap resampling strategy
search_space <- ps(
  cp = p_dbl(0.001, 0.1),
  minsplit = p_int(1,20),
  maxdepth = p_int(1,30), minbucket = p_int(1,20)
) 

meas <- msr("classif.auc")

instance <- tune(
  task = task, 
  learner = learner,
  resampling = rsmp("bootstrap"), 
  measure = msr("classif.auc"),
  search_space = search_space,
  tuner = tnr("grid_search", resolution = 5),
  term_evals = 200
)

# Train the decision tree model with the tuned bagged learner   
learner$param_set$values <- instance$result_learner_param_vals 
learner$train(task, row_ids = train_idx) 

# Obtain the performance of train set with "auc" 
AUC_train <- learner$predict(task, row_ids = train_idx)$score(meas)
AUC_train

# Obtain the performance of internal test set with "auc" 
AUC_test <- learner$predict(task, row_ids = test_idx)$score(meas)
AUC_test

# save the trained learner for further analysis
save(learner, task_train, file = "learner.Rdata") 
 


