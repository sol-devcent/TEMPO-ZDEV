*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPOITTC.........................................*
DATA:  BEGIN OF STATUS_ZPOITTC                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPOITTC                       .
CONTROLS: TCTRL_ZPOITTC
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZPOITTC                       .
TABLES: ZPOITTC                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
