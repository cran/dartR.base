#' @name gl.filter.allna
#' @title Filters loci that are all NA across individuals and/or populations 
#' with all NA across loci
#' @family unmatched filter

#' @description
#' This script deletes loci or individuals with all calls missing (NA),
#'  from a genlight object.
#'  
#' A DArT dataset will not have loci for which the calls are scored all as
#' missing (NA) for a particular individual, but such loci can arise rarely when
#'  populations or individuals are deleted. Similarly, a DArT dataset will not
#'  have individuals for which the calls are scored all as missing (NA) across
#'  all loci, but such individuals may sneak in to the dataset when loci are
#'  deleted. Retaining individual or loci with all NAs can cause issues for
#'  several functions.
#'  
#'  Also, on occasions an analysis will require that there are some loci scored
#'  in each population. Setting by.pop=TRUE will result in removal of loci when
#'  they are all missing in any one population.
#'  
#' Note that loci that are missing for all individuals in a population are
#' not imputed with method 'frequency' or 'HW'. Consider 
#' using the function \code{\link{gl.filter.allna}} with by.pop=TRUE.

#' @param x Name of the input genlight object [required].
#' @param by.pop If TRUE, loci that are all missing in any one population
#' are deleted [default FALSE]
#' @param recalc Recalculate the locus metadata statistics if any individuals
#' are deleted in the filtering [default FALSE].
#' @param verbose Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
#' progress log; 3, progress and results summary; 5, full report
#' [default 2, unless specified using gl.set.verbosity].

#' @author Author(s): Arthur Georges. Custodian: Arthur Georges -- Post to
#' \url{https://groups.google.com/d/forum/dartr}
#' 
#' @examples
#' # SNP data
#'   result <- gl.filter.allna(testset.gl, verbose=3)
#' # Tag P/A data
#'   result <- gl.filter.allna(testset.gs, verbose=3)

#' @family filter functions
#' @import utils patchwork
#' @export
#' @return A genlight object having removed individuals that are scored NA
#' across all loci, or loci that are scored NA across all individuals.

gl.filter.allna <- function(x,
                            by.pop = FALSE,
                            recalc = FALSE,
                            verbose = NULL) {
  # SET VERBOSITY
  verbose <- gl.check.verbosity(verbose)
  
  # FLAG SCRIPT START
  funname <- match.call()[[1]]
  utils.flag.start(func = funname,
                   build = "v.2023.3",
                   verbose = verbose)
  
  # CHECK DATATYPE
  # datatype <- utils.check.datatype(x, accept = c("genlight", "SNP", "SilicoDArT"), verbose = verbose)
  
  # DO THE JOB
  
  if (verbose >= 2) {
    if (by.pop==FALSE){
      cat(
        report(
          "  Identifying and removing loci and individuals scored all 
                missing (NA)\n"
        )
      )
    } else {
      cat(
        report(
          "  Identifying and removing loci that are all missing (NA) 
                    in any one population\n"
        )
      )
    }
  }
    
  if (by.pop==FALSE){
    # Consider loci
    if(verbose >=2){
      cat(report("  Deleting loci that are scored as all missing (NA)\n"))
    }
    na.counter <- 0
    nL <- nLoc(x)
    loc.list <- array(NA,nL)
    matrix_tmp <- as.matrix(x)
    l.names <- locNames(x)
    for (i in 1:nL) {
      row_tmp <- matrix_tmp[, i]
      if (all(is.na(row_tmp))) {
        loc.list[i] <- l.names[i]
        na.counter <- na.counter + 1
      }
    }
    if (na.counter == 0) {
      if (verbose >= 3) {
        cat("  Zero loci that are missing (NA) across all individuals\n")
      }
      x2 <- x
    } else {
      loc.list <- loc.list[!is.na(loc.list)]
      if (verbose >= 3) {
        cat(
          "  ",na.counter,"loci that are missing (NA) across all individuals:",
          paste(loc.list, collapse = ", "),
          "\n"
        )
      }
      
      x2 <- x[, !x$loc.names %in% loc.list]
     x2@other$loc.metrics <- x@other$loc.metrics[!x$loc.names %in% loc.list, ]
      
      if (verbose >= 2) {
        cat("  Deleted\n")
      }
    }
    
    # Consider individuals
    if(verbose >=2){
      cat(report("  Deleting individuals that are scored as all missing (NA)\n"))
    }
    na.counter <- 0
    # nL <- nLoc(x2)
    nI <- nInd(x2)
    # loc.list <- vector("list", nL)
    ind.list <- vector("list", nI)
    matrix_tmp <- as.matrix(x2)
    # l.names <- locNames(x2)
    I.names <- indNames(x2)
    # for (i in 1:nL) {
    for (i in 1:nI) {
      # row_tmp <- matrix_tmp[, i]
      row_tmp <- matrix_tmp[i,]
      if (all(is.na(row_tmp))) {
        # loc.list[i] <- l.names[i]
        ind.list[i] <- I.names[i]
        na.counter <- na.counter + 1
      }
    }
    if (na.counter == 0) {
      if (verbose >= 3) {
        cat("  Zero individuals that are missing (NA) across all loci\n")
      }
    } else {
      ind.list <- ind.list[!is.na(ind.list)]
      if (verbose >= 3) {
        cat(
          "  Individuals that are missing (NA) across all loci:",
          paste(ind.list, collapse = ", "),
          "\n"
        )
      }
      x2 <- x2[!x2$ind.names %in% ind.list,]
      if (verbose >= 2) {
        cat("  Deleted\n")
      }
    }
  }
  
  if (by.pop==TRUE){
    x2 <- x
    if(verbose >=2){
      cat(report("  Deleting loci that are all missing (NA) in any one population\n"))
    }
    total <- 0
    loc.list <- NULL
    for (i in 1:nPop(x2)){
      tmpop <- as.matrix(gl.keep.pop(x2,popNames(x2)[i],verbose=0))
      tmpsums <- apply(tmpop,2,function(x){all(is.na(x))})
      # tmpsums <-  colSums(tmpop)
      tmp.list <- locNames(x2)[tmpsums==TRUE]
      # tmp.list <- locNames(x)[is.na(tmpsums)]
      count <- length(tmp.list)
      if (verbose >= 3){
        cat("    ",popNames(x2)[i],": deleted",count,"loci\n")
      }  
      total <- total + count
      loc.list <- c(loc.list,tmp.list)
    }
    loc.list <- unique(loc.list)
    if (verbose >= 3){
      cat("\n  Loci all NA in one or more populations:",length(loc.list),
          "deleted\n\n")
    }  
    x2 <- gl.drop.loc(x2,loc.list=loc.list,verbose=0)
  }
    
  if (recalc) {
    # Recalculate all metrics, including Call Rate (flags reset in utils 
    #scripts)
    x2 <- gl.recalc.metrics(x2, verbose = verbose)
  } else {
    # Reset the flags as FALSE for all metrics except all na (dealt with 
    #elsewhere)
    if(nLoc(x) != nLoc(x2)){
      x2@other$loc.metrics.flags$AvgPIC <- FALSE
      x2@other$loc.metrics.flags$OneRatioRef <- FALSE
      x2@other$loc.metrics.flags$OneRatioSnp <- FALSE
      x2@other$loc.metrics.flags$PICRef <- FALSE
      x2@other$loc.metrics.flags$PICSnp <- FALSE
      #x2@other$loc.metrics.flags$maf <- FALSE
      x2@other$loc.metrics.flags$FreqHets <- FALSE
      x2@other$loc.metrics.flags$FreqHomRef <- FALSE
      x2@other$loc.metrics.flags$FreqHomSnp <- FALSE
      x2@other$loc.metrics.flags$CallRate <- FALSE
    }
  }
    
  # ADD TO HISTORY
  if(nLoc(x) != nLoc(x2)){
    nh <- length(x2@other$history)
    x2@other$history[[nh + 1]] <- match.call()
  }
    
    # FLAG SCRIPT END
    if (verbose >= 1) {
        cat(report("Completed:", funname, "\n"))
    }
    
    return(x2)
}
