*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMMARA2.........................................*
DATA:  BEGIN OF STATUS_ZMMARA2                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMMARA2                       .
CONTROLS: TCTRL_ZMMARA2
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZMMARA2                       .
TABLES: ZMMARA2                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
