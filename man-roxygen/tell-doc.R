## These functions are emulating the ask&tell hack. If you put ask_Y function as argument instead of a true function (like sin), it will wait as long as you put the Y values using tell_Y() in the same directory. So a 2nd R session will be used to get the X values asked (using ask_X) and then call tell_Y() which will unlock first session. This finally allows an asynchronized IO between many R/matlab/... sessions.
#' @details 
#' 'ask&tell' injection loop to call an external objective function within an inline algorithm (like optim(...))
#' Main idea: pass 'ask_Y' as objectve function argument of algorithm, which will wait until you call 'tell_Y' in another R process.
#' In this secondary process, you can read what X is called using 'ask_X', and when you know what values returns from the external objective, 
#' just call 'tell_Y' to give it.
#' 
#' @author Y. Richet, discussions with D. Sinoquet. Async IO principle was defined by G. Pujol.
#'
#' @param id unique identifier for this asktell loop (default: "0")
#' @param tmp_path temporary directory to store X.tmp & Y.tmp (default: 'tempdir()/../asktell.tmp')
#' @param trace function to display asktell loop status (default : 'cat')
#' @param force_cleanup should we cleanup temporary files before writing (possible conflicting asktell calls) ? (default: FALSE)
#' 
