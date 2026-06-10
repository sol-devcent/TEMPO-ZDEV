*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSTMMT........................................*
DATA:  BEGIN OF STATUS_ZFGSTMMT                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSTMMT                      .
CONTROLS: TCTRL_ZFGSTMMT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSTMMT                      .
TABLES: ZFGSTMMT                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
