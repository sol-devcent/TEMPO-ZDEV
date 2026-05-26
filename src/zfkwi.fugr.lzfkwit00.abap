*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFKWI...........................................*
DATA:  BEGIN OF STATUS_ZFKWI                         .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFKWI                         .
CONTROLS: TCTRL_ZFKWI
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFKWI                         .
TABLES: ZFKWI                          .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
