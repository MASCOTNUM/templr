.onLoad <- function(libname, pkgname) {
    # avoid using user home for .lib storage. Should be in a project dir!
    if (path_home()==path.expand(getwd())) lib_parent = tempdir() else lib_parent=getwd()
    lib = file.path(lib_parent,".lib")
    dir.create(lib,showWarnings = F,recursive = T)
    assign("lib.loc", normalizePath(lib), envir = parent.env(environment()))
    .libPaths(lib.loc)
}

#' Dependencies loader, supports many protocols like github:, gitlab:, ... using remotes::instal_...
#' Will create a local '.lib' directory to store packages installed
#' 
#' @param ... dependencies/libraries/packages to load
#' @param trace display info
#'
#' @importFrom remotes install_github
#' @export
#'
#' @examples
#' \dontrun{
#'   options(data.frame(repos="http://cran.irsn.fr")); import('VGAM')
#' }
import = function(..., trace=function(...) cat(paste0(...,"\n"))) {
    if (!is.function(trace)) trace = function(...){}

    libs <- list(...)
    if (length(libs)>0)
    if (!all(is.na(libs)))
    for (l in stats::na.exclude(unlist(libs))) {
        if (nchar(l)>0) { # else ignore & continue
        trace(paste0("Import '",l,"'"))
        
        if (isTRUE(grep(":",l)==1)) { # GitHub or ...
            src=gsub(":.*","",l)
            n=gsub(".*/","",l)
            path=gsub(".*:","",gsub("/[a-zA-Z0-9]*","",l))
        } else { # CRAN
            src=NULL
            n=l
            path=NULL
        }

        in_base = F
        try(in_base <- base::library(n,logical.return = T,character.only = T, quietly = T),silent = T)
        if (!in_base) {
            in_loc = F
            try(in_loc <- base::library(n,logical.return = T,character.only = T, quietly = T,lib.loc = lib.loc) ,silent = T)
            if (!in_loc) {
                if (!is.null(src)) {
                    trace(paste0("  Using 'remotes' to install ",l))
                    if (!base::library("remotes",logical.return = T,character.only = T, quietly = T))
                        import("remotes")
                    eval(parse(text=paste0("try(remotes::install_",src,"(file.path(path,n),force=T))")))
                } else {
                    trace(paste0("  Using install.packages to install ",l))
                    try(utils::install.packages(l,lib = lib.loc,keep_outputs=T,dependencies=T),silent=F)
                }
                trace(paste0("    Available packages in ",lib.loc,": ",paste0(collapse=", ",utils::installed.packages(lib.loc=lib.loc)[,'Package'])))
            } else trace(paste0("  Loaded package ",l," from ",lib.loc,": ",paste0(collapse=", ",list.files(lib.loc))))

            try_load=F
            try(try_load <- base::library(n,logical.return = T,character.only = T, quietly = T,lib.loc = lib.loc),silent = T)
            if (!try_load) {
                try(try_load <- base::library(n,logical.return = T,character.only = T, quietly = F,lib.loc = lib.loc),silent = F)
                stop(paste0("Cannot load package ",l," as not available in ",lib.loc,": ",paste0(collapse=", ",list.files(lib.loc))))
            }
        } else
            trace(paste0("Loaded package ",l," from ",paste0(collapse=", ",.libPaths())))
        }
    }
}


