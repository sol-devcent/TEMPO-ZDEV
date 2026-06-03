*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPPPDT004.....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT004                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT004                   .
CONTROLS: TCTRL_ZTSPPPDT004
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPPPDT004                   .
TABLES: ZTSPPPDT004                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
