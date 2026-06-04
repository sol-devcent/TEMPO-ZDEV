*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSSUTDT025......................................*
DATA:  BEGIN OF STATUS_ZSSUTDT025                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSSUTDT025                    .
CONTROLS: TCTRL_ZSSUTDT025
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSSUTDT025                    .
TABLES: ZSSUTDT025                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
