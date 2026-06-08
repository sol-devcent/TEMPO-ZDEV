*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSACCGS.......................................*
DATA:  BEGIN OF STATUS_ZFGSACCGS                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSACCGS                     .
CONTROLS: TCTRL_ZFGSACCGS
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSACCGS                     .
TABLES: ZFGSACCGS                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
