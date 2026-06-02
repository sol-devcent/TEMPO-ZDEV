*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSSUTDT005......................................*
DATA:  BEGIN OF STATUS_ZSSUTDT005                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSSUTDT005                    .
CONTROLS: TCTRL_ZSSUTDT005
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSSUTDT005                    .
TABLES: ZSSUTDT005                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
