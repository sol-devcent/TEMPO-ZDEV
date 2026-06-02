*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFARSOFF........................................*
DATA:  BEGIN OF STATUS_ZFARSOFF                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFARSOFF                      .
CONTROLS: TCTRL_ZFARSOFF
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFARSOFF                      .
TABLES: ZFARSOFF                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
