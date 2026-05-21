*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPFIDT02......................................*
DATA:  BEGIN OF STATUS_ZTSPFIDT02                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPFIDT02                    .
CONTROLS: TCTRL_ZTSPFIDT02
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPFIDT02                    .
TABLES: ZTSPFIDT02                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
