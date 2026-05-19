*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSTMMT_CUST...................................*
DATA:  BEGIN OF STATUS_ZFGSTMMT_CUST                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSTMMT_CUST                 .
CONTROLS: TCTRL_ZFGSTMMT_CUST
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSTMMT_CUST                 .
TABLES: ZFGSTMMT_CUST                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
