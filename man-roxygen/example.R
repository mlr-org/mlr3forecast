<%
lrn = mlr3::lrn(id)
pkgs = setdiff(lrn$packages, c("mlr3", "mlr3forecast"))
%>
#' <%= sprintf("@examplesIf mlr3misc::require_namespaces(lrn(\"%s\")$packages, quietly = TRUE)", id) %>
#' # Define the Learner and set parameter values
#' <%= sprintf("learner = lrn(\"%s\")", id)%>
#' print(learner)
#'
#' # Define a Task
#' task = tsk("airpassengers")
#'
#' # Create train and test set
#' <%= sprintf("ids = partition(task)")%>
#'
#' # Train the learner on the training ids
#' <%= sprintf("learner$train(task, row_ids = ids$train)")%>
#'
#' # Print the model
#' print(learner$model)
#'
#' # Importance method
#' if ("importance" %in% learner$properties) print(learner$importance)
#'
#' # Make predictions for the test rows
#' <%= sprintf("predictions = learner$predict(task, row_ids = ids$test)")%>
#'
#' # Score the predictions
#' predictions$score()
