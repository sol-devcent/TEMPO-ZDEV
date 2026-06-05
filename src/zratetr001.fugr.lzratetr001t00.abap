*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZRATETR001......................................*
DATA:  BEGIN OF STATUS_ZRATETR001                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZRATETR001                    .
CONTROLS: TCTRL_ZRATETR001
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZRATETR001                    .
TABLES: ZRATETR001                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
