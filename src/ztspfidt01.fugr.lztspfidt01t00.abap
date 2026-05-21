*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPFIDT01......................................*
DATA:  BEGIN OF STATUS_ZTSPFIDT01                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPFIDT01                    .
CONTROLS: TCTRL_ZTSPFIDT01
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPFIDT01                    .
TABLES: ZTSPFIDT01                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
