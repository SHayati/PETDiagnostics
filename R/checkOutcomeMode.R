checkOutcomeMode <- function(
    workTable
) {

  # checks
  errorMessage <- checkmate::makeAssertCollection()
  #checkDbType(cdm = cdm, messageStore = errorMessage)
  checkmate::assertTRUE(inherits(workTable, 'tbl_dbi'), add = errorMessage)
  checkmate::reportAssertions(collection = errorMessage)

  records <- workTable %>%
    dplyr::select(
     "pregnancy_outcome",
     "pregnancy_mode_delivery")

  #check if miscarriage or TOP has vaginal or c-section delivery
   records <- records %>% dplyr::mutate(
    n = dplyr::if_else(((.data$pregnancy_outcome == 4067106 | .data$pregnancy_outcome == 4081422)
                           & (.data$pregnancy_mode_delivery == 4125611 | .data$pregnancy_mode_delivery ==4015701)),1,0,missing = NULL)) %>%
     dplyr::collect()

  records_n <- records %>%
    dplyr::summarise(
                     no_match = sum(.data$n, na.rm = T),

                     match = sum(.data$n==0, na.rm = T),

                     missing_information = sum(is.na(.data$n)),

                     )
  records_prop <- records_n %>%
    dplyr::summarise(

      no_match = round(.data$no_match / nrow(tibble::as_tibble(workTable)),3)*100,

      match = round(.data$match / nrow(tibble::as_tibble(workTable)),3)*100,

      missing_information = round(.data$missing_information /nrow(tibble::as_tibble(workTable)),3)*100)


records_n <- tibble::as_tibble(reshape2::melt(records_n,variable.names="variable",value.name = "count"))
records_prop <- tibble::as_tibble(reshape2::melt(records_prop,variable.names="variable",value.name = "proportionInPercentage"))

records_long <- records_n %>% dplyr::left_join(records_prop, by = "variable")  %>% dplyr::mutate(Total = nrow(tibble::as_tibble(workTable)))


records <-  NULL
records_n <- NULL
records_prop <- NULL



  return(records_long)

}