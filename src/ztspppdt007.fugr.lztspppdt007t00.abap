*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPPPDT007.....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT007                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT007                   .
CONTROLS: TCTRL_ZTSPPPDT007
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPPPDT007                   .
TABLES: ZTSPPPDT007                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
