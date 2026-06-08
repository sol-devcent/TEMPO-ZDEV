*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFNRCLOSE.......................................*
DATA:  BEGIN OF STATUS_ZFNRCLOSE                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFNRCLOSE                     .
CONTROLS: TCTRL_ZFNRCLOSE
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFNRCLOSE                     .
TABLES: ZFNRCLOSE                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
