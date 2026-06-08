*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIDT004C.......................................*
DATA:  BEGIN OF STATUS_ZFIDT004C                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIDT004C                     .
CONTROLS: TCTRL_ZFIDT004C
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFIDT004C                     .
TABLES: ZFIDT004C                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
