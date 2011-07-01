##' <description>
##'
##' <details>
##' @title <title>
##' @param Y 
##' @param X 
##' @param family 
##' @param method 
##' @param formula 
##' @param ... 
##' @return <return>
##' @author Sam Lendle
##' @export
regress <- function(Y, X, family=binomial(), method="glm", formula=Y~., ...) {
  SL.installed <- "SuperLearner" %in% installed.packages()[,1]
  SL.version <- NULL
  if (method=="glm" || !SL.installed) {
    if (method=="SL") {
      warning("SuperLearner is not installed, using main terms glm", call.=FALSE)
      method <- "glm"
    }
    if (is.null(formula)) formula <- Y~.
    fit <- glm(formula, data=data.frame(Y, X), family=family)
  } else if (method=="SL") {
    require(SuperLearner)
    SL.version <- packageVersion("SuperLearner")$major
    if (SL.version==1) {
      warning("Your version of SuperLearner is out of date. You should consider updating to version 2 if you don't have a good reason not to...")
      fit <- SuperLearner(Y, data.frame(X), family=family, ...)
    }
    else {
      fit <- SuperLearner(Y, data.frame(X), family=family, ...)
    }
  }
  res <- list(fit=fit, method=method, SL.version=SL.version)
  class(res) <- "regress"
  return(res)
}

##' <description>
##'
##' <details>
##' @title <title>
##' @param object 
##' @param newdata 
##' @param ... 
##' @return <return>
##' @author Sam Lendle
##' @export
predict.regress <- function(object, newdata=NULL, X=NULL, Y=NULL, ...) {
  if (object$method=="glm") {
    pred <- predict.glm(object$fit, newdata=newdata, type="response")
  }
  else if (object$method=="SL") {
    if (any(is.null(Y), is.null(X)) & !is.null(newdata)) warning("Original data needs to be passed to predict.regress when using SuperLearner and newdata.  predict may fail depending on the SL.library otherwise...")
    if (object$SL.version==1) {
      if (is.null(newdata)) {
        pred <- predict(object$fit)
      } else {
        pred <-  predict(object$fit, newdata=data.frame(newdata), X=X, Y=Y)$fit
      }
    } else {
      warning("This code (predict for new SL) has not been tested much")
      pred <- predict(object$fit, newdata=newdata, X=X, Y=Y)
    }
  }
  return(pred)
}