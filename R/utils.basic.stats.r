#' @name utils.basic.stats
#' @title Calculates mean observed heterozygosity, mean expected heterozygosity 
#' and FIS per locus, per population and various population differentiation 
#' measures
#'  @family utilities
#'  
#' @description 
#' WARNING: UTILITY SCRIPTS ARE FOR INTERNAL USE ONLY AND SHOULD NOT BE USED BY
#'  END USERS AS THEIR USE OUT OF CONTEXT COULD LEAD TO UNPREDICTABLE OUTCOMES.
#' 
#' @param x A genlight object containing the SNP genotypes [required].
#' 
#' @details
#'  This is a re-implementation of \code{hierfstat::basics.stats} specifically 
#'  for genlight objects. Formula (and hence results) match exactly the original 
#' version of \code{hierfstat::basics.stats} but it is much faster.

#' @author Luis Mijangos and Carlo Pacioni (post to
#' \url{https://groups.google.com/d/forum/dartr})
#' 
#' @examples
#' require("dartR.data")
#' out <- utils.basic.stats(platypus.gl)
#' 
#' @export
#' @return A list with with the statistics for each population

utils.basic.stats <- function(x) {
  
  n.ind <- table(pop(x))
  
  if(any(n.ind <= 1)){
    cat(error(" There are populations with one individual. Please remove populations with one individual or merged them with other populations for this function to work\n"))
    stop()
  }
  
  pop.names <- popNames(x)
  sgl_mat <- lapply(seppop(x),as.matrix)
  pop.vec <- 1:nPop(x)
  
  n.pop <- lapply(pop.vec,function(y){
    apply(sgl_mat[[y]], 2, function(x){
      all(is.na(x))
    })
  })    
  
  n.pop <- Reduce("+",n.pop)
  n.pop <- nPop(x) - n.pop
  
  np <- lapply(pop.vec,function(y){
    colSums(!is.na(sgl_mat[[y]])) 
  })
  
  np <- Reduce(cbind,np)
  
  if(length(pop.names)>1){
    mn <- apply(np,1,function(y){
      1/mean(1/y)
    })
  }else{
    mn <- np
  }
  
  Ho <- lapply(pop.vec,function(y){
    colMeans(sgl_mat[[y]] == 1, na.rm = TRUE)
  })
  Ho <- Reduce(cbind,Ho)
  if(length(pop.names)>1){
    colnames(Ho) <- pop.names
    mHo <- rowMeans(Ho, na.rm=TRUE)
  }else{
    mHo <- Ho
  }
  
  q <- lapply(pop.vec,function(y){
    colMeans(sgl_mat[[y]], na.rm = TRUE)/2
  })
  
  if(length(pop.names)>1){
    Hs <- lapply(pop.vec,function(y){
      n <- nrow(sgl_mat[[y]]) - colSums(apply(sgl_mat[[y]],2,is.na))
      Hs <- 2 * (1-q[[y]]) * q[[y]] - Ho[,y]/2/n
      return(n/(n - 1) * Hs)
    })
  }else{
    n <- nrow(sgl_mat[[1]]) - colSums(apply(sgl_mat[[1]],2,is.na))
    Hs <- 2 * (1-q[[1]]) * q[[1]] - Ho/2/n
    Hs <- n/(n - 1) * Hs
  }
 
  if(length(pop.names)>1){
    Hs <- Reduce(cbind,Hs)
    colnames(Hs) <- pop.names
    q_m <- Reduce(cbind, q)
  }else{
    q_m <- q[[1]]
  }

  sd2 <- q_m^2 + (1 - q_m)^2
  
  if(length(pop.names)>1){
    msp2 <- rowMeans(sd2, na.rm = TRUE)
  }else{
    msp2 <- sd2
  }
  
  mHs <- mn/(mn - 1) * (1 - msp2 - (mHo/(2*mn)))
  
  if(length(pop.names)>1){
    q_mean <- rowMeans(Reduce(cbind,q),na.rm = TRUE)
  }else{
    q_mean <- Reduce(cbind,q)
  }

   # option 1 as hierfstat basic.stats
   # Ht <- 2 * (1-q_mean) * q_mean
   # Ht <- Ht + mHs / mn /n.pop - mHo / 2 / mn / n.pop
   # Dst <- Ht - mHs
   # Dstp <- n.pop/(n.pop - 1) * Dst
   # Htp <- mHs + Dstp
   
   # option 2 as in Nei 1987
   Ht <- 2 * (1-q_mean) * q_mean
   Htp <- Ht + (mHs / mn) - (mHo / (2 * mn * n.pop))
   Dstp <- (n.pop*(Htp-mHs))/(n.pop-1)
   Dst <- Ht - mHs
   
  Fst <- Dst / Ht
  
  Gst_max <- ((n.pop - 1) * (1 - mHs)) / (n.pop - 1 + mHs)
  
  Fstp <- Dstp/Htp
  
  Gst_H <- Fstp / Gst_max
  
  # Dest <- Dstp/(1 - mHs)
  Dest <- ((Htp-mHs)/(1-mHs)) * (n.pop/(n.pop-1))
  
  Fis <- (Hs/Ho)/Hs
  
  mFis <- 1 - (mHo/mHs)
  
  res <- cbind(mHo,
               mHs,
               Ht,
               Dst,
               Htp,
               Dstp,
               Fst,
               Fstp,
               mFis,
               Dest,
               Gst_max,
               Gst_H)
  
  colnames(res) <- c("Ho",
                     "Hs",
                     "Ht",
                     "Dst",
                     "Htp",
                     "Dstp",
                     "Fst",
                     "Fstp",
                     "Fis",
                     "Dest",
                     "Gst_max",
                     "Gst_H")
  
  overall <- colMeans(res, na.rm=TRUE)
  overall["Fst"] <- overall["Dst"] / overall["Ht"]
  overall["Fis"] <- 1 - (overall["Ho"] / overall["Hs"])
  # overall["Dest"] <- (overall["Dstp"] / (1 - overall["Hs"]))
  overall["Dest"] <- (overall["Dstp"] / (1 - overall["Hs"])) * 
    (mean(n.pop)/(mean(n.pop)-1))
  overall["Fstp"] <- overall["Dstp"] / overall["Htp"]
  overall["Gst_H"] <- overall["Fstp"] / overall["Gst_max"]
  
  all.res <- list("Ho" = as.data.frame(round(Ho, 4)), 
                  "Hs" = as.data.frame(round(Hs, 4)), 
                  "Fis" = as.data.frame(round(Fis, 4)), 
                  perloc = as.data.frame(round(res, 4)), 
                  overall = round(overall, 4))
  
  return(all.res)
  
}
