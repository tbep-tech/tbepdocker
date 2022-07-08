library(dplyr)
library(gh)

# identify repos in tbep-tech
repos <- gh::gh(
  "/orgs/{org}/repos",
  org = "tbep-tech",
  type = "all",
  per_page = 100,
  .limit = Inf
  ) 

# get repo topics
repostopics <- repos %>% 
  purrr::map(function(x){
    name <- x$name
    topics <- unlist(x$topics)
    out <- list(topics)
    names(out) <- name
    return(out)
  }) 

# get repos with dashboard topic
dashrepos <- repostopics %>% 
  purrr::map_lgl(function(x) 'dashboard' %in% x[[1]]) %>% 
  repostopics[.] %>% 
  purrr::map(names) %>% 
  unlist() %>% 
  sort()

'seagrasstransect/master/otbseagrass.Rmd'
'sso-dash/master/future-risk.Rmd'

# these are repos where the index is not the rmd file
excrepos <- c('tidalcreek-dash', 'wq-dash', 'seagrasstransect', 'nekton-dash', 'tbepRSparrow-control')
dashrepos <- dashrepos[!dashrepos %in% excrepos]

scrplib <- function(fl){
  
  tmp <- readLines(url(fl))
  tmp <- grep('^library\\(', tmp, value = T)

  out <- sapply(tmp, function(x) x %>% gsub('library\\(|\\)', '', .)) %>% 
    unlist %>% 
    unique %>% 
    sort
  
  if(length(out) == 0)
    out <- NULL
  
  return(out)
  
}

fls <- paste0('https://raw.githubusercontent.com/tbep-tech/', dashrepos, '/master/index.Rmd')

pkgs <- purrr::map(fls, scrplib) 

flsexc <- c(
  'https://raw.githubusercontent.com/tbep-tech/tidalcreek-dash/master/tidalcreek-dash.Rmd',
  'https://raw.githubusercontent.com/tbep-tech/wq-dash/master/wq-dash.Rmd',
  'https://raw.githubusercontent.com/tbep-tech/nekton-dash/master/nekton-dash.Rmd',
  'https://raw.githubusercontent.com/tbep-tech/tbepRSparrow-control/master/app.R',
  # 'https://raw.githubusercontent.com/tbep-tech/seagrasstransect/master/otbseagrass.Rmd',
  'https://raw.githubusercontent.com/tbep-tech/sso-dash/master/future-risk.Rmd'
  )
excpkgs <- purrr::map(flsexc, scrplib)
  
pkgs <- c(pkgs, excpkgs) %>% 
  unlist %>% 
  unique %>% 
  sort

pkgsdkr <- paste0("install.packages('", pkgs, "', repos='http://cran.rstudio.com/')")
pkgsdkr <- paste0('RUN R -e "', pkgsdkr, '"')

# writeLines(pkgsdkr, 'tmp.txt')
