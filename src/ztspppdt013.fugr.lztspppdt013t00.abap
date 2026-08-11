*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPPPDT013.....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT013                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT013                   .
CONTROLS: TCTRL_ZTSPPPDT013
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPPPDT013                   .
TABLES: ZTSPPPDT013                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
