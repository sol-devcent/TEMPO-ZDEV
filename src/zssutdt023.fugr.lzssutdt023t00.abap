*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSSUTDT023......................................*
DATA:  BEGIN OF STATUS_ZSSUTDT023                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSSUTDT023                    .
CONTROLS: TCTRL_ZSSUTDT023
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSSUTDT023                    .
TABLES: ZSSUTDT023                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
