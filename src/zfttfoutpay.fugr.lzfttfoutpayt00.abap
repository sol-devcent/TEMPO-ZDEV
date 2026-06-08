*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFTTFOUTPAY.....................................*
DATA:  BEGIN OF STATUS_ZFTTFOUTPAY                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFTTFOUTPAY                   .
CONTROLS: TCTRL_ZFTTFOUTPAY
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFTTFOUTPAY                   .
TABLES: ZFTTFOUTPAY                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
