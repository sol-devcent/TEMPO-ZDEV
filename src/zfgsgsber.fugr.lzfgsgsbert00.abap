*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSGSBER.......................................*
DATA:  BEGIN OF STATUS_ZFGSGSBER                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSGSBER                     .
CONTROLS: TCTRL_ZFGSGSBER
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSGSBER                     .
TABLES: ZFGSGSBER                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
