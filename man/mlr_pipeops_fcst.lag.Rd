% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/PipeOpFcstLag.R
\name{mlr_pipeops_fcst.lag}
\alias{mlr_pipeops_fcst.lag}
\alias{PipeOpFcstLag}
\title{Creat Lags of Target Variable}
\description{
...
}
\section{Parameters}{

The parameters are the parameters inherited from \link[mlr3pipelines:PipeOpTaskPreproc]{mlr3pipelines::PipeOpTaskPreproc},
as well as the following parameters:
\itemize{
\item \code{lags} :: \code{integer()}\cr
The lags to create.
}
}

\examples{
set.seed(1234L)
}
\section{Super classes}{
\code{\link[mlr3pipelines:PipeOp]{mlr3pipelines::PipeOp}} -> \code{\link[mlr3pipelines:PipeOpTaskPreproc]{mlr3pipelines::PipeOpTaskPreproc}} -> \code{PipeOpFcstLag}
}
\section{Methods}{
\subsection{Public methods}{
\itemize{
\item \href{#method-PipeOpFcstLag-new}{\code{PipeOpFcstLag$new()}}
\item \href{#method-PipeOpFcstLag-clone}{\code{PipeOpFcstLag$clone()}}
}
}
\if{html}{\out{
<details open><summary>Inherited methods</summary>
<ul>
<li><span class="pkg-link" data-pkg="mlr3pipelines" data-topic="PipeOp" data-id="help"><a href='../../mlr3pipelines/html/PipeOp.html#method-PipeOp-help'><code>mlr3pipelines::PipeOp$help()</code></a></span></li>
<li><span class="pkg-link" data-pkg="mlr3pipelines" data-topic="PipeOp" data-id="predict"><a href='../../mlr3pipelines/html/PipeOp.html#method-PipeOp-predict'><code>mlr3pipelines::PipeOp$predict()</code></a></span></li>
<li><span class="pkg-link" data-pkg="mlr3pipelines" data-topic="PipeOp" data-id="print"><a href='../../mlr3pipelines/html/PipeOp.html#method-PipeOp-print'><code>mlr3pipelines::PipeOp$print()</code></a></span></li>
<li><span class="pkg-link" data-pkg="mlr3pipelines" data-topic="PipeOp" data-id="train"><a href='../../mlr3pipelines/html/PipeOp.html#method-PipeOp-train'><code>mlr3pipelines::PipeOp$train()</code></a></span></li>
</ul>
</details>
}}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-PipeOpFcstLag-new"></a>}}
\if{latex}{\out{\hypertarget{method-PipeOpFcstLag-new}{}}}
\subsection{Method \code{new()}}{
Initializes a new instance of this Class.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{PipeOpFcstLag$new(id = "fcst.lags", param_vals = list())}\if{html}{\out{</div>}}
}

\subsection{Arguments}{
\if{html}{\out{<div class="arguments">}}
\describe{
\item{\code{id}}{(\code{character(1)})\cr
Identifier of resulting object, default \code{"fcst.lags"}.}

\item{\code{param_vals}}{(named \code{list()})\cr
List of hyperparameter settings, overwriting the hyperparameter settings that would
otherwise be set during construction. Default \code{list()}.}
}
\if{html}{\out{</div>}}
}
}
\if{html}{\out{<hr>}}
\if{html}{\out{<a id="method-PipeOpFcstLag-clone"></a>}}
\if{latex}{\out{\hypertarget{method-PipeOpFcstLag-clone}{}}}
\subsection{Method \code{clone()}}{
The objects of this class are cloneable with this method.
\subsection{Usage}{
\if{html}{\out{<div class="r">}}\preformatted{PipeOpFcstLag$clone(deep = FALSE)}\if{html}{\out{</div>}}
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
