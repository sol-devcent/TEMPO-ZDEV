*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFTTFCG.........................................*
DATA:  BEGIN OF STATUS_ZFTTFCG                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFTTFCG                       .
CONTROLS: TCTRL_ZFTTFCG
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFTTFCG                       .
TABLES: ZFTTFCG                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
