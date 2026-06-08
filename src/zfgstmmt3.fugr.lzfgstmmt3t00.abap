*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSTMMT3.......................................*
DATA:  BEGIN OF STATUS_ZFGSTMMT3                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSTMMT3                     .
CONTROLS: TCTRL_ZFGSTMMT3
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSTMMT3                     .
TABLES: ZFGSTMMT3                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
