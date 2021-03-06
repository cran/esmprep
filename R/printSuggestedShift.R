#' printSuggestedShift
#
#' @description printSuggestedShift prints to the console which ESM prompts are suggested to be modified.
#
#' @param esDfShift a list. Each element of the list must be a data.frame. This argument is generated by \code{\link{suggestShift}} if at least one ESM questionnaire is eligible for shifting to a neighboring prompt. See \strong{Details} for more information.
#
#' @param RELEVANTVN_ES a list. This list is generated by function \code{\link{setES}} and it is extended once either by function \code{\link{genDateTime}} or by function \code{\link{splitDateTime}}.
#
#' @details The output to the console shall give the user the necessary information to decide whether lines of data might be shifted and where they shall be shifted to (by altering the values of the variable PROMPT) .
#
#' @return No return value. See \strong{Details} for more information.
#
#' @examples
#' # o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#' # Prerequisites in order to execute printSuggestedShift. Start ------
#' # Use example list delivered with the package
#' RELEVANTINFO_ES <- RELEVANTINFO_ES
#' # Use example list delivered with the package
#' RELEVANTVN_ES <- RELEVANTVN_ESext
#' # esAssigned is a list of datasets, delivered with the package. It is
#' # the result of the assignment of the ESM questionnaires to ALL 8
#' # participants in the reference dataset.
#' noEndDf <- missingEndDateTime(esAssigned[["ES"]], RELEVANTVN_ES)
#' identDf <- esIdentical(noEndDf, RELEVANTVN_ES)
#' sugShift <- suggestShift(identDf, 100, RELEVANTINFO_ES, RELEVANTVN_ES)
#' # Prerequisites in order to execute printSuggestedShift. End --------
#' # -------------------------------------------------------
#' # Run function 21 of 29; see esmprep functions' hierarchy.
#' # -------------------------------------------------------
#' # Display the result of function 'suggestShift' in the console.
#' printSuggestedShift(sugShift, RELEVANTVN_ES)
#' # o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#
#' @seealso Exemplary code (fully executable) in the documentation of \code{\link{esmprep}} (function 21 of 29).
#
#' @export
#
printSuggestedShift <- function(esDfShift, RELEVANTVN_ES = NULL) {
	
	if(!is.list(esDfShift) & length(esDfShift)!=3) {
    		stop("Relevant input is missing. Use this function only either after executing function 'suggestShift' or after executing 'makeShift'. BEWARE: If function 'suggestShift' doesn't suggest at least one shift, the function 'printSuggestedShift' makes no sense, i.e. if there is no ESM questionnaire eligible for shifting, both functions 'printSuggestedShift' and 'makeShift' can be ingored! Continue with function 'expectedPromptIndex'.")
    } else if(is.character(esDfShift[["suggestShiftDf"]]) && esDfShift[["suggestShiftDf"]] == "No SHIFT suggested.") {
    		stop("All lines were checked by function 'suggestShift'. No SHIFT suggested. Continue with function 'expectedPromptIndex'.")
    }
    
    # All 3 elements of the list must be of type data.frame.
    if( !all(sapply(esDfShift, FUN = is.data.frame)) ) {
        stop("Function 'printSuggestedShift' only accepts a single data frame as argument.")
    }
    
    # Error handling function for all set-up lists generated by setES and setREF.
    # Both lists RELEVANTVN_ES and RELEVANTVN_REF get extended either by function
    # genDateTime or by function splitDateTime!
    SETUPLISTCheck(RELEVANTINFO_ES=NULL,
    			   RELEVANTVN_ES=RELEVANTVN_ES,
    			   RELEVANTVN_REF=NULL)
    
    if(length(match(c("SHIFT", "SHIFTKEY"), colnames(esDfShift[["esDf"]])))==0) {
        stop("Function 'printSuggestedShift' either needs the dataframe to contain the column 'SHIFT' or the column 'SHIFTKEY'. Use this function only either after executing function 'suggestShift' or after executing 'makeShift'.")
    }
    
    if(sum(esDfShift[["esDf"]][,"SHIFT"])>0) {
        
        countIdx <- esDfShift[["printShiftDf"]][,"countIdx"]
        for(k in 1:sum(esDfShift[["esDf"]][,"SHIFT"])) {
            idxShiftDisplay <- esDfShift[["printShiftDf"]][countIdx==k,"indices"]
            
            # Print esDf to console:
            print(esDfShift[["esDf"]] [idxShiftDisplay,
            # Columns
            c("ID", "KEY", RELEVANTVN_ES[["ES_SVY_NAME"]], "CV_ES", "CV_ESDAY",
            RELEVANTVN_ES[["ES_START_DATETIME"]], "ST", "PROMPT",
            "PROMPTEND", "ES_MULT", "SHIFT", "SHIFTKEY", "LAG_MINUTES")])
            cat("--------------------------------------------------------------------------\n\n")
        }

    }
}
