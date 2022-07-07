library(box)
scrptlib <- function(fl){
  
  box::use(
    dplyr[...]
  )
  
  tmp <- readLines(url(fl))
  tmp <- grep('^library\\(', tmp, value = T)

  out <- sapply(tmp, function(x) x %>% gsub('library\\(|\\)', '', .)) %>% 
    unlist %>% 
    unique %>% 
    sort %>% 
    paste(collapse = ', ')
  
  if(nchar(out) == 0)
    out <- 'none'
  
  return(out)
  
}

fl <- 'https://raw.githubusercontent.com/tbep-tech/seagrasstransect-training-dash/master/index.Rmd'