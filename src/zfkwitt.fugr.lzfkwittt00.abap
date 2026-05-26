*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFKWITT.........................................*
DATA:  BEGIN OF STATUS_ZFKWITT                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFKWITT                       .
CONTROLS: TCTRL_ZFKWITT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFKWITT                       .
TABLES: ZFKWITT                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
