*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFVATA1.........................................*
DATA:  BEGIN OF STATUS_ZFVATA1                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFVATA1                       .
CONTROLS: TCTRL_ZFVATA1
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFVATA1                       .
TABLES: ZFVATA1                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
