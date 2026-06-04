*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSSUTDT022......................................*
DATA:  BEGIN OF STATUS_ZSSUTDT022                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSSUTDT022                    .
CONTROLS: TCTRL_ZSSUTDT022
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSSUTDT022                    .
TABLES: ZSSUTDT022                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
