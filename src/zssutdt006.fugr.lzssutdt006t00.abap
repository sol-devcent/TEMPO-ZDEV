*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSSUTDT006......................................*
DATA:  BEGIN OF STATUS_ZSSUTDT006                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSSUTDT006                    .
CONTROLS: TCTRL_ZSSUTDT006
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSSUTDT006                    .
TABLES: ZSSUTDT006                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
