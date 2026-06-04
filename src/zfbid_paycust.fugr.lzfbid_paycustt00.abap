*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFBID_PAYCUST...................................*
DATA:  BEGIN OF STATUS_ZFBID_PAYCUST                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFBID_PAYCUST                 .
CONTROLS: TCTRL_ZFBID_PAYCUST
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZFBID_PAYCUST                 .
TABLES: ZFBID_PAYCUST                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
