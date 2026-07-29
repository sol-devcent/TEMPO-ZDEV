*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZWMDT004........................................*
DATA:  BEGIN OF STATUS_ZWMDT004                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZWMDT004                      .
CONTROLS: TCTRL_ZWMDT004
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZWMDT004                      .
TABLES: ZWMDT004                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
