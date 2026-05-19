*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZACCDTU.........................................*
DATA:  BEGIN OF STATUS_ZACCDTU                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZACCDTU                       .
CONTROLS: TCTRL_ZACCDTU
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZACCDTU                       .
TABLES: ZACCDTU                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
