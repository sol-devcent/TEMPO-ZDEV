*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPLBC...........................................*
DATA:  BEGIN OF STATUS_ZPLBC                         .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPLBC                         .
CONTROLS: TCTRL_ZPLBC
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZPLBC                         .
TABLES: ZPLBC                          .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
