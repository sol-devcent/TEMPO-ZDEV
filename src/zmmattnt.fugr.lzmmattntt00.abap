*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMMATTNT........................................*
DATA:  BEGIN OF STATUS_ZMMATTNT                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMMATTNT                      .
CONTROLS: TCTRL_ZMMATTNT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZMMATTNT                      .
TABLES: ZMMATTNT                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
