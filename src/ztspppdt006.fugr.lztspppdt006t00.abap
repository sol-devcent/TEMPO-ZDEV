*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPPPDT006.....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT006                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT006                   .
CONTROLS: TCTRL_ZTSPPPDT006
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPPPDT006                   .
TABLES: ZTSPPPDT006                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
