*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPMMDT007.....................................*
DATA:  BEGIN OF STATUS_ZTSPMMDT007                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPMMDT007                   .
CONTROLS: TCTRL_ZTSPMMDT007
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPMMDT007                   .
TABLES: ZTSPMMDT007                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
