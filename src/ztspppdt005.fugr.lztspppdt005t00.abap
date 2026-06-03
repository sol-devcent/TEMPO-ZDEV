*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPPPDT005.....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT005                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT005                   .
CONTROLS: TCTRL_ZTSPPPDT005
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPPPDT005                   .
TABLES: ZTSPPPDT005                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
