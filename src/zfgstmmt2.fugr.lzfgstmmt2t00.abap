*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSTMMT2.......................................*
DATA:  BEGIN OF STATUS_ZFGSTMMT2                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSTMMT2                     .
CONTROLS: TCTRL_ZFGSTMMT2
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSTMMT2                     .
TABLES: ZFGSTMMT2                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
