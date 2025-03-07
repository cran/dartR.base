% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gl.read.vcf.r
\name{gl.read.vcf}
\alias{gl.read.vcf}
\title{Converts a vcf file into a genlight object}
\usage{
gl.read.vcf(vcffile, ind.metafile = NULL, mode = "genotype", verbose = NULL)
}
\arguments{
\item{vcffile}{A vcf file (works only for diploid data) [required].}

\item{ind.metafile}{Optional file in csv format with metadata for each
individual (see details for explanation) [default NULL].}

\item{mode}{"genotype" all heterozygous sites will be coded as 1 regardless ploidy level, 
dosage: sites will be codes as copy number of alternate allele [default genotype]}

\item{verbose}{Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
progress log; 3, progress and results summary; 5, full report
[default 2, unless specified using gl.set.verbosity].}
}
\value{
A genlight object.
}
\description{
This function needs package vcfR, please install it.
}
\details{
The ind.metadata file needs to have very specific headings. First a heading
called id. Here the ids have to match the ids in the dartR object. 
The following column headings are optional.
pop: specifies the population membership of each individual. lat and lon
specify spatial coordinates (in decimal degrees WGS1984 format). Additional
columns with individual metadata can be imported (e.g. age, gender).
Note also that this function checks to see if there are input of mode, missing input of mode 
will issue the user with an error. "Dosage" mode of this function assign ploidy levels as maximum copy number of alternate alleles. 
Please carefully check the data if "dosage" mode is used.
}
\examples{
\dontrun{
# read in vcf and convert to format as DArT data
obj <- gl.read.vcf(system.file('extdata/test.vcf', package='dartR'), 
                   ind.metafile = "metafile.csv")
# read in vcf and convert to format as dosage
obj <- gl.read.vcf(system.file('extdata/test.vcf', package='dartR'), 
                   ind.metafile = "metafile.csv", mode="dosage")
}
}
\author{
Bernd Gruber, Ching Ching Lau (Post to \url{https://groups.google.com/d/forum/dartr})
}
