% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gi2gl.R, R/gl2gi.r
\name{gl2gi}
\alias{gl2gi}
\alias{gi2gl}
\title{Converts a genind object into a genlight object}
\usage{
gi2gl(gi, parallel = FALSE, verbose = NULL)

gl2gi(x, probar = FALSE, verbose = NULL)
}
\arguments{
\item{gi}{A genind object [required].}

\item{parallel}{Switch to deactivate parallel version. It might not be worth
to run it parallel most of the times [default FALSE].}

\item{verbose}{Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
progress log; 3, progress and results summary; 5, full report
[default 2 or as specified using gl.set.verbosity].}

\item{x}{A genlight object [required].}

\item{probar}{If TRUE, a progress bar will be displayed for long loops
[default TRUE].}
}
\value{
A genlight object, with all slots filled.

A genind object, with all slots filled.
}
\description{
Converts a genind object into a genlight object

Converts a genlight object to genind object
}
\details{
Be aware due to ambiguity which one is the reference allele a combination of
 gi2gl(gl2gi(gl)) does not return an identical object (but in terms of
 analysis this conversions are equivalent)

This function uses a faster version of df2genind (from the adegenet
 package)
}
\seealso{
Other linker: 
\code{\link{gl2bayesAss}()},
\code{\link{gl2bayescan}()},
\code{\link{gl2bpp}()},
\code{\link{gl2demerelate}()},
\code{\link{gl2eigenstrat}()},
\code{\link{gl2faststructure}()},
\code{\link{gl2gds}()},
\code{\link{gl2genalex}()},
\code{\link{gl2genepop}()},
\code{\link{gl2geno}()},
\code{\link{gl2hiphop}()},
\code{\link{gl2phylip}()},
\code{\link{gl2plink}()},
\code{\link{gl2related}()},
\code{\link{gl2sa}()},
\code{\link{gl2structure}()},
\code{\link{gl2treemix}()},
\code{\link{gl2vcf}()}

Other linker: 
\code{\link{gl2bayesAss}()},
\code{\link{gl2bayescan}()},
\code{\link{gl2bpp}()},
\code{\link{gl2demerelate}()},
\code{\link{gl2eigenstrat}()},
\code{\link{gl2faststructure}()},
\code{\link{gl2gds}()},
\code{\link{gl2genalex}()},
\code{\link{gl2genepop}()},
\code{\link{gl2geno}()},
\code{\link{gl2hiphop}()},
\code{\link{gl2phylip}()},
\code{\link{gl2plink}()},
\code{\link{gl2related}()},
\code{\link{gl2sa}()},
\code{\link{gl2structure}()},
\code{\link{gl2treemix}()},
\code{\link{gl2vcf}()}
}
\author{
Bernd Gruber (Post to \url{https://groups.google.com/d/forum/dartr})
}
\concept{linker}
