#' @name gl.report.secondaries
#' @title Reports loci containing secondary SNPs in sequence tags and calculates
#'   number of invariant sites
#' @family matched report

#' @description SNP datasets generated by DArT include fragments with more than
#'   one SNP (that is, with secondaries). They are recorded separately with the
#'   same CloneID (=AlleleID). These multiple SNP loci within a fragment are
#'   likely to be linked, and so you may wish to remove secondaries.

#'   This function reports statistics associated with secondaries, and the
#'   consequences of filtering them out, and provides three plots. The first is
#'   a boxplot, the second is a barplot of the frequency of secondaries per
#'   sequence tag, and the third is the Poisson expectation for those
#'   frequencies including an estimate of the zero class (no. of sequence tags
#'   with no SNP scored).
#'   
#' @param x Name of the genlight object [required].
#' @param nsim The number of simulations to estimate the mean of the Poisson
#'   distribution [default 1000].
#' @param taglength Typical length of the sequence tags [default 69].
#' @param plot.display Specify if plot is to be produced [default TRUE].
#' @param plot.theme Theme for the plot. See Details for options [default
#'   theme_dartR()].
#' @param plot.colors Vector with two color names for the borders and fill
#' [default c("#2171B5", "#6BAED6")].
#' @param plot.dir Directory to save the plot RDS files [default as specified 
#' by the global working directory or tempdir()]
#' @param plot.file Filename (minus extension) for the RDS plot file [Required for plot save]
#' @param verbose Verbosity: 0, silent or fatal errors; 1, begin and end; 2,
#'   progress log; 3, progress and results summary; 5, full report
#'   [default 2, unless specified using gl.set.verbosity].
#'   
#' @details The function \code{\link{gl.filter.secondaries}} will filter out the
#'   loci with secondaries retaining only one sequence tag.

#'   Heterozygosity as estimated by the function
#'   \code{\link{gl.report.heterozygosity}} is in a sense relative, because it
#'   is calculated against a background of only those loci that are polymorphic
#'   somewhere in the dataset. To allow intercompatibility across studies and
#'   species, any measure of heterozygosity needs to accommodate loci that are
#'   invariant (autosomal heterozygosity. See Schmidt et al 2021). However, the
#'   number of invariant loci are unknown given the SNPs are detected as single
#'   point mutational variants and invariant sequences are discarded, and
#'   because of the particular additional filtering pre-analysis. Modelling the
#'   counts of SNPs per sequence tag as a Poisson distribution in this script
#'   allows estimate of the zero class, that is, the number of invariant loci.
#'   This is reported, and the veracity of the estimate can be assessed by the
#'   correspondence of the observed frequencies against those under Poisson
#'   expectation in the associated graphs. The number of invariant loci can then
#'   be optionally provided to the function
#'   \code{\link{gl.report.heterozygosity}} via the parameter n.invariants.

#'   In case the calculations for the Poisson expectation of the number of
#'   invariant sequence tags fail to converge, try to rerun the analysis with a
#'   larger \code{nsim} values.

#'   This function now also calculates the number of invariant sites (i.e.
#'   nucleotides) of the sequence tags (if \code{TrimmedSequence} is present in
#'   \code{x$other$loc.metrics}) or estimate these by assuming that the average
#'   length of the sequence tags is 69 nucleotides. Based on the Poisson
#'   expectation of the number of invariant sequence tags, it also estimates the
#'   number of invariant sites for these to eventually provide an estimate of
#'   the total number of invariant sites.

#'  \strong{Note}, previous version of
#'   \code{dartR} would only return an estimate of the number of invariant
#'   sequence tags (not sites).

#'   If plot.file is specified, plots are saved to the directory specified by the user, or the global
#'   default working directory set by gl.set.wd() or to the tempdir().

#'   Examples of other themes that can be used can be consulted in:
#'    \itemize{
#'   \item \url{https://ggplot2.tidyverse.org/reference/ggtheme.html} and \item
#'   \url{https://yutannihilation.github.io/allYourFigureAreBelongToUs/ggthemes/}
#'    }
#' \itemize{
#'   \item n.total.tags Number of sequence tags in total
#'   \item n.SNPs.secondaries Number of secondary SNP loci that would be removed
#'   on filtering
#'   \item n.invariant.tags Estimated number of invariant sequence tags
#'   \item n.tags.secondaries Number of sequence tags with secondaries
#'   \item n.inv.gen Number of invariant sites in sequenced tags
#'   \item mean.len.tag Mean length of sequence tags
#'   \item n.invariant Total Number of invariant sites (including invariant
#'   sequence tags)
#'   \item k Lambda: mean of the Poisson distribution of number of SNPs in the
#'   sequence tags
#' }
#' @author Custodian: Arthur Georges (Post to
#'   \url{https://groups.google.com/d/forum/dartr})
#'   
#' @examples
#' require("dartR.data")
#' test <- gl.filter.callrate(platypus.gl,threshold = 1)
#' n.inv <- gl.report.secondaries(test)
#' gl.report.heterozygosity(test, n.invariant = n.inv[7, 2])
#' 
#' @seealso
#' \code{\link{gl.filter.secondaries}},\code{\link{gl.report.heterozygosity}},
#' \code{\link{utils.n.var.invariant}}
#' @references Schmidt, T.L., Jasper, M.-E., Weeks, A.R., Hoffmann, A.A., 2021.
#'   Unbiased population heterozygosity estimates from genome-wide sequence
#'   data. Methods in Ecology and Evolution n/a.

#' @importFrom stats dpois
#' @import patchwork
#' @export
#' @return A data.frame with the list of parameter values


gl.report.secondaries <- function(x,
                                  nsim = 1000,
                                  taglength = 69,
                                  plot.display = TRUE,
                                  plot.theme = theme_dartR(),
                                  plot.colors = NULL,
                                  plot.dir=NULL,
                                  plot.file=NULL,
                                  verbose = NULL) {
  # SET VERBOSITY
  verbose <- gl.check.verbosity(verbose)
  if(verbose==0){plot.display <- FALSE}
  
  # SET WORKING DIRECTORY
  plot.dir <- gl.check.wd(plot.dir,verbose=0)
  
  # SET COLOURS
  if(is.null(plot.colors)){
    plot.colors <- c("#2171B5", "#6BAED6")
  } else {
    if(length(plot.colors) > 2){
      if(verbose >= 2){cat(warn("  More than 2 colors specified, only the first 2 are used\n"))}
      plot.colors <- plot.colors[1:2]
    }
  }

  # FLAG SCRIPT START
  funname <- match.call()[[1]]
  utils.flag.start(func = funname,
                   build = "v.2023.3",
                   verbose = verbose)
  
  # CHECK DATATYPE
  datatype <- utils.check.datatype(x, accept = c("genlight", "SNP"), verbose = verbose)
  
  # FUNCTION SPECIFIC ERROR CHECKING
  
  if (isFALSE("AlleleID" %in% names(x$other$loc.metrics)) &
      isFALSE("CloneID" %in% names(x$other$loc.metrics))) {
    stop(
      error(
        "Neither CloneID or AlleleID metrics were found in the slot 
                loc.metrics, which are required for this function to work\n"
      )
    )
  }
  
  # DO THE JOB
  
  n.invariant <-
    CloneID <-
    TrimmedSequence <- n.variant <- lenTrimSeq <- NA
  
  # Extract the clone ID number
  a <-
    strsplit(as.character(x@other$loc.metrics$AlleleID), "\\|")
  b <- unlist(a)[c(TRUE, FALSE, FALSE)]
  
  # set up to estimate variable and inv sites in sequenced tags, and mean tag
  # length
  proc.data <-
    data.table(x$other$loc.metrics)  # using data.table
  if (isFALSE("CloneID" %in% names(x$other$loc.metrics))) {
    proc.data[, `:=`(CloneID, b)]
  }
  setkey(proc.data, CloneID)
  if ("TrimmedSequence" %in% names(x$other$loc.metrics)) {
    proc.data[, `:=`(lenTrimSeq, nchar(as.character(TrimmedSequence)))]
    proc.data[, `:=`(n.variant, .N), by = CloneID]
    proc.data[, `:=`(n.invariant, lenTrimSeq - n.variant)]
    
    # the number of invariant sites of the genotyped tags
    n.inv.gen <-
      proc.data[data.table(unique(CloneID)), 
                sum(n.invariant), mult = "first"]
    # the mean length of the sequenced tags
    mean.len.tag <-
      proc.data[data.table(unique(CloneID)),
                mean(lenTrimSeq), mult = "first"]
  } else {
    mean.len.tag <- taglength
    proc.data[, `:=`(n.variant, .N), by = CloneID]
    # The mean number of SNPs for each tag
    mean.nSNP.tag <-
      proc.data[data.table(unique(CloneID)), 
                mean(n.variant), mult = "first"]
    # The number of tags
    n.inv.gen <-
      round((mean.len.tag - mean.nSNP.tag) * 
              proc.data[, length(unique(CloneID))], 0)
    cat(warn(
      paste(
        "The column 'TrimmedSequence' was not found in loc.metrics\n",
        "Mean tag length assumed to be",
        taglength,
        "\n"
      )
    ))
  }
  if (verbose >= 2) {
    cat(report("Counting ....\n"))
  }
  x.secondaries <- x[, duplicated(b)]
  
  nloc.with.secondaries <- table(duplicated(b))[2]
  if (!is.na(nloc.with.secondaries)) {
    freqs_1 <- c(0, as.numeric(table(b)))
    secondaries_plot <- as.data.frame(freqs_1)
    colnames(secondaries_plot) <- "freqs"
    
    # Boxplot
   #if (plot.display) {
      p1 <-
        ggplot(secondaries_plot, aes(y = freqs)) + 
        geom_boxplot(color = plot.colors[1], fill = plot.colors[2]) + 
        coord_flip() + 
        plot.theme +
        xlim(range = c(-1, 1)) + 
        scale_y_discrete(limits = c(as.character(unique(freqs_1)))) + 
        theme(axis.text.y = element_blank(),
              axis.ticks.y = element_blank()) + 
        ggtitle("Boxplot")
      
      # Barplot
      freqs_2 <- c(0, table(as.numeric(table(b))))
      secondaries_plot_2 <- as.table(freqs_2)
      names(secondaries_plot_2) <-
        seq(1:(length(secondaries_plot_2))) - 1
      secondaries_plot_2 <-
        as.data.frame(secondaries_plot_2)
      colnames(secondaries_plot_2) <- c("freq", "count")
      
      freq <- NULL
      
      p2 <-
        ggplot(secondaries_plot_2, aes(x = freq, y = count)) + 
        geom_col(color = plot.colors[1], fill = plot.colors[2]) +
        xlab("Frequency") +
        ylab("Count") + 
        ggtitle("Observed Frequency of SNPs per Sequence Tag") + 
        plot.theme
    #}
    
    # Plot Histogram with estimate of the zero class
    if (verbose >= 2) {
      cat(report(
        "Estimating parameters (lambda) of the Poisson expectation\n"
      ))
    }
    
    # Calculate the mean for the truncated distribution
    freqs <- c(0, table(as.numeric(table(b))))
    tmp <- NA
    for (i in 1:length(freqs)) {
      tmp[i] <- freqs[i] * (i - 1)
    }
    tmean <- sum(tmp) / sum(freqs)
    
    # Set a random seed, close to 1
    seed <- tmean
    
    # Set convergence criterion
    delta <- 1e-05
    
    # Use the mean of the truncated distribution to compute lambda for the 
    # untruncated distribution
    k <- seed
    for (i in 1:nsim) {
      if (verbose >= 2) {
        print(k)
      }
      k.new <- tmean * (1 - exp(-k))
      if (abs(k.new - k) <= delta) {
        if (verbose >= 2) {
          cat(report("  Converged on Lambda of", k.new, "\n\n"))
        }
        fail <- FALSE
        k <- k.new
        break
      }
      if (i == nsim) {
        if (verbose >= 2) {
          cat(
            important(
              "  Failed to converge: No reliable estimate of 
                            invariant loci\n"
            )
          )
        }
        fail <- TRUE
        break
      }
      k <- k.new
    }
    
    # Size of the truncated distribution
    if (!fail) {
      # Size of the truncated set
      n <- sum(freqs)  
      # Fraction that is the truncated set
      tp <- 1 - dpois(x = 0, lambda = k) 
      # Estimate of the whole set
      rn <- round(n / tp, 0)  
      # cat('\n Estimated size of the zero class',
      # round(dpois(x=0,lambda=k)*rn,0),'\n')
      # Table for the reconstructed set
      reconstructed <-
        dpois(x = 0:(length(freqs) - 1), lambda = k) * rn
      reconstructed <- as.table(reconstructed)
      names(reconstructed) <-
        seq(1:(length(reconstructed))) - 1
      
      title <-
        paste0("Poisson Expectation (zero class ",
               round(dpois(
                 x = 0, lambda = k
               ) * rn, 0),
               " invariant loci)")
      
      reconstructed_plot <- as.data.frame(reconstructed)
      colnames(reconstructed_plot) <- c("freq", "count")
      
      # Barplot
      
        p3 <-
          ggplot(reconstructed_plot, aes(x = freq, y = count)) + 
          geom_col(color = plot.colors[1], fill = plot.colors[2]) + 
          xlab("Frequency") +
          ylab("Count") + 
          ggtitle(title) + 
          plot.theme
        
        # PRINTING OUTPUTS using package patchwork
        p4 <- p1 / p2 / p3 + plot_layout(heights = c(1, 2, 2))
        if (plot.display) {print(p4)}
    }
    
    if (fail) {
      p4 <- p1 / p2
      if (plot.display) {print(p4)}
    }
    
    if(!is.null(plot.file)){
      tmp <- utils.plot.save(p4,
                             dir=plot.dir,
                             file=plot.file,
                             verbose=verbose)
    }
    
    } else {
        k <- NA
        if (plot.display) {
            cat(warn(
                "  Warning: No loci with secondaries, no plot produced\n"
            ))
        }
    }
    
    # Identify secondaries in the genlight object
    n.total.tags <- table(duplicated(b))[1]
    n.SNPs.secondaries <- 0
    n.invariant.tags <- NA
    n.tags.secondaries <- NA
    n.invariant <- NA
    cat("  Total number of SNP loci scored:", nLoc(x), "\n")
    if (is.na(table(duplicated(b))[2])) {
      cat("    Number of secondaries: 0 \n")
    } else {
      cat("   Number of sequence tags in total:", n.total.tags, "\n")
      if (fail) {
        cat("    Number of invariant sequence tags cannot be estimated\n")
      } else {
        n.invariant.tags <- round(dpois(x = 0, lambda = k) * rn, 0)
        cat("   Estimated number of invariant sequence tags:",
            n.invariant.tags,
            "\n")
      }
      n.tags.secondaries <-
        sum(table(as.numeric(table(b)))) - table(as.numeric(table(b)))[1]
      cat("   Number of sequence tags with secondaries:",
          n.tags.secondaries,
          "\n")
      n.SNPs.secondaries <- table(duplicated(b))[2]
      cat(
        "   Number of secondary SNP loci that would be removed on 
            filtering:",
        n.SNPs.secondaries,
        "\n"
      )
      cat("   Number of SNP loci that would be retained on filtering:",
          n.total.tags,
          "\n")
      cat("   Number of invariant sites in sequenced tags:",
          n.inv.gen,
          "\n")
      cat("   Mean length of sequence tags:", mean.len.tag, "\n")
      n.invariant <-
        round(n.invariant.tags * mean.len.tag + n.inv.gen, 0)
      cat(
        "   Total Number of invariant sites (including invariant sequence 
            tags):",
        n.invariant,
        "\n"
      )
      if (verbose >= 3) {
        cat(report(
          " Tabular 1 to K secondaries (refer plot)\n",
          table(as.numeric(table(b))),
          "\n"
        ))
      }
    }
    
    # FLAG SCRIPT END
    
    if (verbose >= 1) {
      cat(report("Completed:", funname, "\n"))
    }
    
    # RETURN
    return(data.frame(
      Param = c(
        "n.total.tags",
        "n.SNPs.secondaries",
        "n.invariant.tags",
        "n.tags.secondaries",
        "n.inv.gen",
        "mean.len.tag",
        "n.invariant",
        "Lambda"
      ),
      Value = c(
        unname(n.total.tags),
        n.SNPs.secondaries,
        n.invariant.tags,
        n.tags.secondaries,
        n.inv.gen,
        mean.len.tag,
        n.invariant,
        k
      )
    ))
  }
  