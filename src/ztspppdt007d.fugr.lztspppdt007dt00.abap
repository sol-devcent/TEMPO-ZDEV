*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPPPDT007D....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT007D                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT007D                  .
CONTROLS: TCTRL_ZTSPPPDT007D
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPPPDT007D                  .
TABLES: ZTSPPPDT007D                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
