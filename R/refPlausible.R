#' refPlausible
#
#' @description refPlausible enables the user to quickly check the reference dataset concerning the expeced ESM time period for each participant.
#
#' @param refDf a data.frame. The reference dataset.
#
#' @param RELEVANTVN_REF a list. This list is generated by function \code{\link{setREF}} and it is extended once either by function \code{\link{genDateTime}} or by function \code{\link{splitDateTime}}.
#
#' @param units a character. This character must be exactly one of the following options: auto, secs, mins, hours, days, weeks. For more information see the R base function \code{\link{difftime}}.
#
#' @details The units of the ESM period can be selected by the user, namely one of the following: auto, secs, mins, hours, days, weeks. For more information enter ?difftime in the R console. The prompts per participant, as defined by the user within the reference dataset, are expected to be an increasing time series within a respective ESM day. Therefore, if there are two prompts set at the exact same time, this represents an anomaly. The same is true of any prompt that is earlier in time instead of later (as expected) than the previous prompt (time reversals are not tolerated). Finally, if the function detects any duplicates among the participant IDs, it will return an error message and displays the problematic lines of the reference dataset in the R console.
#
#' @return A data.frame, i.e. \code{refDf}. The returned data.frame will have two additional columns:
#' \enumerate{
#' \item ESM_PERIOD in the selected time period, e.g. days.
#' \item TIME_ANOMALY, i.e. a possible anomaly concerning the expected increase in the time sequence of the prompts in the reference dataset (returned only if there is at least one time anomaly).
#' \item PROMPT_NEXTDAY, i.e. at which of the participant's prompts is a time anomaly suspected (returned only if there is at least one time anomaly).
#' }
#' See \strong{Details} for more information.
#
#' @examples
#' # o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#' # Prerequisites in order to execute refPlausible. Start ------
#' # Use example list delivered with the package
#' RELEVANTVN_REF <- RELEVANTVN_REFext
#' # Prerequisites in order to execute refPlausible. End --------
#' # ------------------------------------------------------
#' # Run function 8 of 29; see esmprep functions' hierarchy.
#' # ------------------------------------------------------
#' # In an ESM study all participants answer questionnaires during a time period which
#' # usually is equal across all participants (e.g. seven days). This function enables the
#' # user to check whether in the reference dataset the ESM period is plausible. For
#' # instance, a negative ESM time period would clearly be implausible, e.g. the user
#' # setting the beginning of the ESM time period after the end of it (which is
#' # impossible unless a functioning time machine is involved :-) ).
#' referenceDfNew1 <- refPlausible(refDf=referenceDfNew, units="days", RELEVANTVN_REF)
#' # o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o=o
#
#' @seealso Exemplary code (fully executable) in the documentation of \code{\link{esmprep}} (function 8 of 29).
#
#' @export
#
refPlausible <- function(refDf=NULL, units="days", RELEVANTVN_REF) {
	
	if(!is.data.frame(refDf)) {
		stop("Argument 'refDf' must be of class data.frame.")
	}
	
	if(!is.character(units)) {
		stop("Argument 'units' must be of class character.")
	}
	
	if(!any(c("auto", "secs", "mins", "hours", "days", "weeks") %in% units)) {
		stop("Argument 'units' received an invalid value, please select exactly one of the following options: 'auto', 'secs', 'mins', 'hours', 'days', 'weeks'. For details enter '?difftime' in the R console.")
	}
	
	# Error handling function for all set-up lists generated by setES and setREF.
    # Both lists RELEVANTVN_ES and RELEVANTVN_REF get extended either by function
    # genDateTime or by function splitDateTime!
    SETUPLISTCheck(RELEVANTINFO_ES=NULL,
    			   RELEVANTVN_ES=NULL,
    			   RELEVANTVN_REF=RELEVANTVN_REF)
    	
    	if(any(duplicated(refDf[,RELEVANTVN_REF[["REF_ID"]]]))) {
		
		whichDupl <- which(duplicated(refDf[,RELEVANTVN_REF[["REF_ID"]]]))
		duplCatch <- c()
		for(k in 1:length(whichDupl)) {
			duplCatch <- c(duplCatch, which(refDf[,RELEVANTVN_REF[["REF_ID"]]] == refDf[whichDupl[k],RELEVANTVN_REF[["REF_ID"]]]))
		}
		
		dupl <- rep(0, times=nrow(refDf))
		dupl[duplCatch] <- 1
		cat("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n")
		cat("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n")
		cat(paste0("Duplicates in reference dataset. See column ", RELEVANTVN_REF[["REF_ID"]], ":\n"))
		cat("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n")
		print(refDf[duplCatch,])
		cat("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n")
		cat("- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -\n\n")
		stop("There are duplicated participant IDs in the reference dataset (see printed relevant part in the R console). This must be changed before proceeding!")
		
	}
	
	timeDiffUnit <- base::difftime(refDf[,RELEVANTVN_REF[["REF_END_DATETIME"]]],
						 refDf[,RELEVANTVN_REF[["REF_START_DATETIME"]]],
						 units=units)
	refDf[,paste0("ESM_PERIOD", toupper(units))] <- as.numeric(timeDiffUnit)
	
	if(!is.null(refDf[,RELEVANTVN_REF[["REF_ST"]]]) && length(refDf[,RELEVANTVN_REF[["REF_ST"]]]) > 1) {
		
		# Is the overall ESM start time per participant among the prompts?
		startTimeInPromptsColNames <- c(RELEVANTVN_REF[["REF_START_TIME"]], RELEVANTVN_REF[["REF_ST"]])
		startTimeInPromptsBool <- apply(refDf[,startTimeInPromptsColNames],
							MARGIN=1, function(x) {
								any(as.character(x[2:length(startTimeInPromptsColNames)]) %in% as.character(x[1]))
							})
		
		# Is the overall ESM end time per participant among the prompts?
		endTimeInPromptsColNames <- c(RELEVANTVN_REF[["REF_END_TIME"]], RELEVANTVN_REF[["REF_ST"]])
		endTimeInPromptsBool <- apply(refDf[,endTimeInPromptsColNames],
							MARGIN=1, function(x) {
								any(as.character(x[2:length(endTimeInPromptsColNames)]) %in% as.character(x[1]))
							})
		
		if(any(!(startTimeInPromptsBool & endTimeInPromptsBool))) {
			
			print(refDf[!(startTimeInPromptsBool & endTimeInPromptsBool),])
			stop(paste0("At least one entry in one of the two colums ", RELEVANTVN_REF[["REF_START_TIME"]], " or ", RELEVANTVN_REF[["REF_END_TIME"]], " is NOT among the respective participant's prompts, although it must be. See R console."))
			
		}
		
		# Another possible source for errors, e.g. in function 'esAssign',
		# i.e. setting versus not setting the argument midnightPrompt to TRUE. 
		idTimeAnomaly <- promptSwitchDate <- c()
		
		refDfInternal <- refDf
		columnsHMS <- as.character(RELEVANTVN_REF[["REF_ST"]])
		for(i in columnsHMS) {
			refDfInternal[,i] <- as.numeric(lubridate::hms(refDfInternal[,i]))
		}
		
		for(j in 1:nrow(refDf)) {
			
			# For participant j compute time diff between scheduled prompts
			jDiffTemp0 <- base::diff(as.numeric(refDfInternal[j,RELEVANTVN_REF[["REF_ST"]]]))
			# Copy first value of jDiffTemp0 and set at first position; this way
			# there are as many entries as there are prompts.
			jDiffTemp <- jDiffTemp0[c(1,1:length(jDiffTemp0))]
			
			if(any(jDiffTemp <= 0)) {
				idTimeAnomaly <- c(idTimeAnomaly, 1)
				promptSwitchDate <- c(promptSwitchDate, which((jDiffTemp <= 0) == TRUE))
				message(paste0("Is there an anomaly in the prospective time sequence in row ", j, " of the reference dataset? See column ", RELEVANTVN_REF[["REF_ID"]], " participant ", refDf[j,RELEVANTVN_REF[["REF_ID"]]], ".\nMaybe this is not an anomaly but instead signaling the necessity to set the argument 'midnightPrompt' to 'TRUE' in the function 'esAssign'.\n"))
			} else {
				idTimeAnomaly <- c(idTimeAnomaly, 0)
				promptSwitchDate <- c(promptSwitchDate, 0)
			}
		}
		
		if(!all(idTimeAnomaly == 0)) {
			refDf[,"TIME_ANOMALY"] <- idTimeAnomaly
			refDf[,"PROMPT_NEXTDAY"] <- promptSwitchDate
		}
	}
	
	return(refDf)
}
