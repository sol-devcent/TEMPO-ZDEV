*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFNOEFAKTUR.....................................*
DATA:  BEGIN OF STATUS_ZFNOEFAKTUR                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFNOEFAKTUR                   .
CONTROLS: TCTRL_ZFNOEFAKTUR
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFNOEFAKTUR                   .
TABLES: ZFNOEFAKTUR                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
