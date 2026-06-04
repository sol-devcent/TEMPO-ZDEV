*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFBIH_PAYCUST...................................*
DATA:  BEGIN OF STATUS_ZFBIH_PAYCUST                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFBIH_PAYCUST                 .
CONTROLS: TCTRL_ZFBIH_PAYCUST
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZFBIH_PAYCUST                 .
TABLES: ZFBIH_PAYCUST                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
