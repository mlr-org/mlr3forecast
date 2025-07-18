% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tsf.R
\name{download_zenodo_record}
\alias{download_zenodo_record}
\title{Download tsf file from Zenodo}
\usage{
download_zenodo_record(record_id = 4656222, dataset_name = "m3_yearly_dataset")
}
\arguments{
\item{record_id}{(\code{character(1)}) the Zenodo record ID.}

\item{dataset_name}{(\code{character(1)}) the name of the dataset to download.}
}
\value{
(\code{\link[data.table:data.table]{data.table::data.table()}}).
}
\description{
Downloads a tsf file from Zenodo using the provided record ID and dataset name.
}
\examples{
\dontrun{
dt = download_zenodo_record(record_id = 4656222, dataset_name = "m3_yearly_dataset")

# optional renaming
setnames(dt, c("id", "date", "value"))

# transform into single task
task = as_task_fcst(dt)

# or split up for forecast learners that don't allow key columns
tasks = split(dt, ~id) |> map(remove_named, "id") |> map(as_task_fcst)
}
}
\references{
Godahewa, Rakshitha, Bergmeir, Christoph, Webb, I G, Hyndman, J R, Montero-Manso, Pablo (2021).
\dQuote{Monash time series forecasting archive.}
\emph{arXiv preprint arXiv:2105.06643}.
}
