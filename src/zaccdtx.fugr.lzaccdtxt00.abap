*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZACCDTX.........................................*
DATA:  BEGIN OF STATUS_ZACCDTX                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZACCDTX                       .
CONTROLS: TCTRL_ZACCDTX
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZACCDTX                       .
TABLES: ZACCDTX                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
