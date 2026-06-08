*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFNRVALID.......................................*
DATA:  BEGIN OF STATUS_ZFNRVALID                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFNRVALID                     .
CONTROLS: TCTRL_ZFNRVALID
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFNRVALID                     .
TABLES: ZFNRVALID                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
