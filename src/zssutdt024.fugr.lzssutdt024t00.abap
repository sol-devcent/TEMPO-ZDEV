*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSSUTDT024......................................*
DATA:  BEGIN OF STATUS_ZSSUTDT024                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSSUTDT024                    .
CONTROLS: TCTRL_ZSSUTDT024
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSSUTDT024                    .
TABLES: ZSSUTDT024                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
