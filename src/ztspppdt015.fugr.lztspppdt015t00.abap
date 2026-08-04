*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPPPDT015.....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT015                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT015                   .
CONTROLS: TCTRL_ZTSPPPDT015
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPPPDT015                   .
TABLES: ZTSPPPDT015                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
