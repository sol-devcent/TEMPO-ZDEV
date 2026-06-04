*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSSUTDT021......................................*
DATA:  BEGIN OF STATUS_ZSSUTDT021                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSSUTDT021                    .
CONTROLS: TCTRL_ZSSUTDT021
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSSUTDT021                    .
TABLES: ZSSUTDT021                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
