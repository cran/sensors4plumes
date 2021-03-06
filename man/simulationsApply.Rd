\name{ simulationsApply }
\alias{simulationsApply}

\title{ Apply functions value-wise, location-wise, or plume-wise to Simulations }

\description{ 
Apply functions to the \code{@values} of Simulations objects or to Raster* objects. Functions can be applied to any margin: value-wise, plume-wise, or location-wise. The results can be summarised by a second function. Processing of the data may be done in blocks, this allows to process data that does not fit into memory. However, this only works if input and output of a single function fit into memory. 
}
\usage{
simulationsApply(simulations, 
  locations = 1:nLocations(simulations), 
  plumes = 1:nPlumes(simulations), 
  kinds = 1:nKinds(simulations), 
  fun = NA, fun_p = NA, fun_l = NA, fun_pl = NA, 
  fun_Rp = NA, fun_Rl = NA, fun_Rpl = NA, fun_Rpl_cellStats = NA, 
  nameSave = "simulationsApply", overwrite = FALSE,
  chunksize = 1e+7, keepSubset = FALSE, ...)
}

\arguments{
\item{simulations}{ Simulations object or Raster* object }
\item{locations}{ indices of locations, i.e. rows of \code{simulations@values} to be taken into account }
\item{plumes}{ indices of plumes, i.e. columns of \code{simulations@values} to be taken into account }
\item{kinds}{ index or name of the layer of \code{simulations@values} to be used }
\item{fun}{ function to be applied to all values of the subset at once, see details }
\item{fun_p}{ function to be applied plume-wise, see details }
\item{fun_l}{ function to be applied location-wise, see details }
\item{fun_pl}{ function to be applied value-wise, see details }
\item{fun_Rp}{ function to be applied to the result of \code{fun_p}, see details }
\item{fun_Rl}{ function to be applied to the result of \code{fun_l}, see details }
\item{fun_Rpl}{ function to be applied to the result of \code{fun_pl}, see details }
\item{fun_Rpl_cellStats}{ character string of function to be applied to the result of \code{fun_pl} via \code{\link[raster]{cellStats}}, must be one of \code{c("sum", "mean", "min", "max", "sd", "skew", "rms")}}
\item{nameSave}{ filename for the raster file in case the result does not fit into memory; if \code{FALSE} the function stops with a warning and does not create a file }
\item{overwrite}{ boolean, if the file at \code{nameSave} may be overwritten } 
\item{chunksize}{ maximal number of cells to be processed at once -- forwarded to \code{\link[raster]{blockSize}} inside }
\item{keepSubset}{ boolean, if the subset of the values of \code{simulations} generated by \code{locations} and \code{plumes} is to be kept}
\item{...}{ further parameters to be passed on to called functions}
}

%It can be one of the following characters: 'sum', 'prod', 'min', 'max'; or it has to be a function of one parameter \code{x} and the parameter \code{na.rm} (or \code{...}). For \code{summaryPlumes} the \code{fun} must be associative, i.e. \code{fun(x, fun(y))} must be the same as \code{fun(c(x,y))}. }
%\item{initial}{ value to start the summary function from, it should be the neutral element, i.e. \code{fun(x, initial)} must be the same as \code{fun(x)}. -- If \code{fun} is defined by a character string, the correct one is used automatically if no other \code{initial} is indicated: (\code{0, 1, Inf, -Inf}) for (\code{sum, prod, min, max}) respectively. }
%\item{summaryFun}{ function to summarise the results for the individual plumes/locations; it must have the  parameters \code{x}, \code{weight}, and \code{na.rm} (if either of the parameters is missing, it needs a ... argument) }
%\item{weight}{ the weight to be used by \code{summaryFun}; either a numerical of length that fits the number of plumes (\code{summaryPlumes}) / locations (\code{summaryLocations}); or a caracter indicating a column of \code{simulations@plumes} (\code{summaryPlumes}) / column of \code{simulations@locations@data}.}


\value{
List of values and arrays (dimensions: references (locations, plumes), output parameters of the function):
  \code{"result_global"}: result of \code{fun}
  \code{"result_plumes"}: result of \code{fun_p}  
  \code{"result_locations"}: result of \code{fun_l} 
  \code{"result_global_plumes"}: result of \code{fun_Rp}
  \code{"result_global_locations"}: result of \code{fun_Rl}
  \code{"result_locationsplumes"}: result of \code{fun_pl}; \code{RasterBrick}
  \code{"result_global_locationsplumes"}: result of \code{fun_Rpl} 
  \code{"result_global_locationsplumes"}: result of \code{fun_Rpl_cellStats}
  \code{"subset"}: subset of data, according to \code{plumes} and \code{locations}
If some function cannot be applied (wrong parameters, input not in memory...), the result of this function is not returned with a warning.
%Note that these list entries may be vectors/matrices instead if there are less dimensions. This may depend on if the data is processed in memory or chunkwise (no warning)!
}

\details{ 
The defaults for \code{locations}, \code{plumes} and \code{kinds} only work for \code{simulations} of class Simulations. If it is of class raster, the user has to provide these parameters. If \code{plumes} or \code{locations} contain an index several times, these plumes / locations are considered that many times, also order is kept. Invalid indices cause stop with warning.

The functions must have a certain form, else the function stops with a warning:
they need the parameters \code{x} for the input values and \code{nout}, the length of the output (to generate the arrays to hold the results). Several functions to be applied can be specified. However, \code{fun_Rp}, \code{fun_Rl}, and \code{fun_Rpl} make only sense if the functions that generate their input are specified. \code{fun_Rp} and \code{fun_Rl} need the additional parameter \code{weight}, inside of \code{simulationsApply} this parameter is set to the data frames associated with the plumes or locations, respectively: you may refer to names of these data frames inside the functions (default is overwritten); if \code{simulations} is a \code{\link[raster]{raster}} object, no values are inserted as \code{weight} -- the parameter must be given, but unless it has default values you cannot refer to it in the function. \code{fun_Rpl} needs the parameters \code{weight_l} and \code{weight_p} which are replaced by the data frames associated with locations and plumes.
All functions are checked by \code{\link{replaceDefault}} automatically with \code{type = "fun.simulationsApply"}; \code{fun_Rp}, \code{fun_Rl} with \code{type = "funR.simulationsApply"} and \code{fun_Rpl} with \code{type = "funRR.simulationsApply"}. 

The output of \code{fun}, \code{fun_p}, or \code{fun_l} is supposed to be small enough to keep it in memory; if not, it stops with a warning.
The results of \code{fun_pl} may be too big to keep in memory. If \code{nameSave} is a filename, these data are saved as raster files.
The subset of values (defined by \code{plumes} and \code{locations}) is only kept if it fits into memory.
}

\author{ Kristina B. Helle, \email{kristina.helle@uni-muenster.de} }

\examples{
\dontrun{
## may create files
demo(radioactivePlumes_addProperties)

# number of not detected plumes for given set of 10 sensors, 
# weighted by total dose of plumes
sensors = sample.int(nLocations(radioactivePlumes), 10)
  
nondetection = function(x, threshold = 1e-7, nout = 1){ 
  all(x[,2] < threshold)
}

sumWeighted = function(x, weight, nout = 1){
  sum(x * weight$totalDose)
}

weightedSumUndetectedAtSensors = simulationsApply(
  simulations = radioactivePlumes,
  locations = sensors,
  fun_p = nondetection,
  fun_Rp = sumWeighted
)

# map of average time until detection of plumes
# if a plume never reaches a location it is counted as being there after a week
meanDetectionTime = function(x, nout = 1){
  y = x
  y[is.na(x)] = 7 * 86400 
  z = mean(y, na.rm = TRUE)
}

mapMeanDetectionTime = simulationsApply(
  simulations = radioactivePlumes,
  kinds = 3,
  fun_l = meanDetectionTime
)
radioactivePlumes@locations@data$meanDetectionTime = 
  mapMeanDetectionTime[["result_locations"]]
spplot(radioactivePlumes@locations, zcol = "meanDetectionTime")

# general ratio and difference of 'maxdose' and 'finaldose'
ratioMaxFinal =  function(x, nout = 2){
  ratio = x[2]/x[1]
  diff = x[2] - x[1]
  ratio[!is.finite(ratio)] = NA
  out = c(ratio, diff)
}
valuesRatio = simulationsApply(
  simulations = radioactivePlumes,
  fun_pl = ratioMaxFinal,
  fun_Rpl_cellStats = "mean",
  nameSave = "ratio"
)
hist(valuesRatio[["result_locationsplumes"]], 1, 
  xlim = c(0,1), breaks = c(seq(0, 1, 0.01), 10000))
hist(valuesRatio[["result_locationsplumes"]], 2, 
  xlim = c(-0.001, 0.001), breaks = c(-1000, seq(-0.001, 0.001, 0.0001), 1000))

}

%# linear model
%# early detection
%## chunks / no chunks
}
