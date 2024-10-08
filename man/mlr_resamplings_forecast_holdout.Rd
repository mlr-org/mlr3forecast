% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ResamplingForecastHoldout.R
\name{mlr_resamplings_forecast_holdout}
\alias{mlr_resamplings_forecast_holdout}
\alias{ResamplingForecastHoldout}
\title{Forecast Holdout Resampling}
\description{
Splits data into a training set and a test set.
Parameter \code{ratio} determines the ratio of observation going into the training set (default: 2/3).
}
\section{Dictionary}{

This \link[mlr3:Resampling]{Resampling} can be instantiated via the \link[mlr3misc:Dictionary]{dictionary} \link[mlr3:mlr_resamplings]{mlr_resamplings} or with the associated sugar function \link[mlr3:mlr_sugar]{rsmp()}:

\if{html}{\out{<div class="sourceCode">}}\preformatted{mlr_resamplings$get("forecast_cv")
rsmp("forecast_cv")
}\if{html}{\out{</div>}}
}

\section{Parameters}{

\itemize{
\item \code{ratio} (\code{numeric(1)})\cr
Ratio of observations to put into the training set.
}
}

\examples{
# Create a task with 10 observations
task = tsk("penguins")
task$filter(1:10)

# Instantiate Resampling
holdout = rsmp("forecast_holdout", ratio = 0.5)
holdout$instantiate(task)

# Individual sets:
holdout$train_set(1)
holdout$test_set(1)

# Disjunct sets:
intersect(holdout$train_set(1), holdout$test_set(1))

# Internal storage:
holdout$instance # simple list
}
\seealso{
\itemize{
\item Chapter in the \href{https://mlr3book.mlr-org.com/}{mlr3book}:
\url{https://mlr3book.mlr-org.com/chapters/chapter3/evaluation_and_benchmarking.html#sec-resampling}
\item Package \CRANpkg{mlr3spatiotempcv} for spatio-temporal resamplings.
\item \link[mlr3misc:Dictionary]{Dictionary} of \link[=Resampling]{Resamplings}: \link{mlr_resamplings}
\item \code{as.data.table(mlr_resamplings)} for a table of available \link[=Resampling]{Resamplings} in the running session (depending on the loaded packages).
\item \CRANpkg{mlr3spatiotempcv} for additional \link{Resampling}s for spatio-temporal
tasks.
}

Other Resampling: 
\code{\link{mlr_resamplings_forecast_cv}}
}
\concept{Resampling}
\section{Super class}{
\code{\link[mlr3:Resampling]{mlr3::Resampling}} -> \code{ResamplingForecastHoldout}
}
\section{Active bindings}{
\if{html}{\out{<div class="r6-active-bindings">}}
\describe{
\item{\code{iters}}{(\code{integer(1)})\cr
Returns the number of resampling iterations, depending on the values stored in the \code{param_set}.}
}
\if{html}{\out{</div>}}
}
\section{Methods}{
\subsection{Public methods}{
\itemize{
\item \href{#method-ResamplingForecastHoldout-new}{\code{ResamplingForecastHoldout$new()}}
\item \href{#method-ResamplingForecastHoldout-clone}{\code{ResamplingForecastHoldout$clone()}}
}
}
\if{html}{\out{
<details><summary>Inherited methods</summary>
<ul>
<li><span class="pkg-link" data-pkg="mlr3" data-topic="Resampling" data-id="format"><a href='../../mlr3/html/Resampling.html#method-Resampling-format'><code>mlr3::Resampling$format()</code></a></span></li>
<li><span class="pkg-link" data-pkg="mlr3" data-topic="Resampling" data-id="help"><a href='../../mlr3/html/Resampling.html#method-Resampling-help'><code>mlr3::Resampling$help()</code></a></span></li>
<li><span class="pkg-link" data-pkg="mlr3" data-topic="Resampling" data-id="instantiate"><a href='../../mlr3/html/Resampling.html#method-Resampling-instantiate'><code>mlr3::Resampling$instantiate()</code></a></span></li>
<li><span class="pkg-link" data-pkg="mlr3" data-topic="Resampling" data-id="print"><a href='../../mlr3/html/Resampling.html#method-Resampling-print'><code>mlr3::Resampling$print()</code></a></span></li>
<li><span class="pkg-link" data-pkg="mlr3" data-topic="Resampling" data-id="test_set"><a href='../../mlr3/html/Resampling.html#method-Resampling-test_set'><code>mlr3::Resampling$test_set()</code></a></span></li>
<li><span class="pkg-link" data-pkg="mlr3" data-topic="Resampling" data-id="train_set"><a href='../../mlr3/html/Resampling.html#method-Resampling-train_set'><code>mlr3::Resampling$train_set()</code></a></span></li>
</ul>
</details>
}}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-ResamplingForecastHoldout-new"></a>}}
\if{latex}{\out{\hypertarget{method-ResamplingForecastHoldout-new}{}}}
\subsection{Method \code{new()}}{
Creates a new instance of this \link[R6:R6Class]{R6} class.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ResamplingForecastHoldout$new()}\if{html}{\out{</div>}}
}

}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-ResamplingForecastHoldout-clone"></a>}}
\if{latex}{\out{\hypertarget{method-ResamplingForecastHoldout-clone}{}}}
\subsection{Method \code{clone()}}{
The objects of this class are cloneable with this method.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{ResamplingForecastHoldout$clone(deep = FALSE)}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{deep}}{Whether to make a deep clone.}
}
\if{html}{\out{</div>}}
}
}
}
