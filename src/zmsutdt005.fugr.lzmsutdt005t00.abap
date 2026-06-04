*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMSUTDT005......................................*
DATA:  BEGIN OF STATUS_ZMSUTDT005                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMSUTDT005                    .
CONTROLS: TCTRL_ZMSUTDT005
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZMSUTDT005                    .
TABLES: ZMSUTDT005                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
