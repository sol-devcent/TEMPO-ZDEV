*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFKWINO.........................................*
DATA:  BEGIN OF STATUS_ZFKWINO                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFKWINO                       .
CONTROLS: TCTRL_ZFKWINO
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFKWINO                       .
TABLES: ZFKWINO                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
