*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSSUTCT001......................................*
DATA:  BEGIN OF STATUS_ZSSUTCT001                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSSUTCT001                    .
CONTROLS: TCTRL_ZSSUTCT001
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZSSUTCT001                    .
TABLES: ZSSUTCT001                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
