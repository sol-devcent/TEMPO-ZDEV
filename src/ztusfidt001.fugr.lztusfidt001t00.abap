*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTUSFIDT001.....................................*
DATA:  BEGIN OF STATUS_ZTUSFIDT001                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTUSFIDT001                   .
CONTROLS: TCTRL_ZTUSFIDT001
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTUSFIDT001                   .
TABLES: ZTUSFIDT001                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
