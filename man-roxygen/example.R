<%
learner = mlr3::lrn(id)
pkgs = setdiff(learner$packages, c("mlr3", "mlr3forecast"))
%>
#' @examplesIf mlr3misc::require_namespaces(learner$packages, quietly = TRUE)
#' # Define the Learner and set parameter values
#' <%= sprintf("learner = lrn(\"%s\")", id)%>
#' print(learner)
#'
#' # Define a Task
#' task = tsk("airpassengers")
#'
#' # Create train and test set
#' resampling = rsmp("fcst.holdout", ratio = 0.7)$instantiate(task)
#'
#' # Train the learner on the training ids
#' learner$train(task, row_ids = resampling$train_set(1))
#'
#' # Print the model
#' print(learner$model)
#'
#' # Importance method
#' if ("importance" %in% learner$properties) print(learner$importance)
#'
#' # Make predictions for the test rows
#' predictions = learner$predict(task, row_ids = resampling$test_set(1))
#'
#' # Score the predictions
#' predictions$score()
