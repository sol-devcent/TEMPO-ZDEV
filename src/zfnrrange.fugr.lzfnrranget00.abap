*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFNRRANGE.......................................*
DATA:  BEGIN OF STATUS_ZFNRRANGE                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFNRRANGE                     .
CONTROLS: TCTRL_ZFNRRANGE
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFNRRANGE                     .
TABLES: ZFNRRANGE                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
