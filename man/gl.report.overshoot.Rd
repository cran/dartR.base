% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gl.report.overshoot.r
\name{gl.report.overshoot}
\alias{gl.report.overshoot}
\title{Reports loci for which the SNP has been trimmed from the sequence tag
 along with the adaptor}
\usage{
gl.report.overshoot(x, verbose = NULL)
}
\arguments{
\item{x}{Name of the genlight object [required].}

\item{verbose}{Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
progress log; 3, progress and results summary; 5, full report
[default NULL, unless specified using gl.set.verbosity].}
}
\value{
An unaltered genlight object
}
\description{
This function checks the position of the SNP within the trimmed sequence tag
and identifies those for which the SNP position is outside the trimmed
sequence tag. This can happen, rarely, when the sequence containing the SNP
resembles the adaptor.
}
\details{
The SNP genotype can still be used in most analyses, but functions like
gl2fasta() will present challenges if the SNP has been trimmed from the 
sequence tag.
Resultant ggplot(s) and the tabulation(s) are saved to the session's
temporary directory.
}
\examples{
gl.report.overshoot(testset.gl)

}
\seealso{
\code{\link{gl.filter.overshoot}}

Other matched report: 
\code{\link{gl.filter.excess.het}()},
\code{\link{gl.report.allna}()},
\code{\link{gl.report.callrate}()},
\code{\link{gl.report.hamming}()},
\code{\link{gl.report.locmetric}()},
\code{\link{gl.report.maf}()},
\code{\link{gl.report.pa}()},
\code{\link{gl.report.rdepth}()},
\code{\link{gl.report.reproducibility}()},
\code{\link{gl.report.secondaries}()},
\code{\link{gl.report.taglength}()}
}
\author{
Custodian: Arthur Georges -- Post to 
\url{https://groups.google.com/d/forum/dartr}
}
\concept{matched report}
