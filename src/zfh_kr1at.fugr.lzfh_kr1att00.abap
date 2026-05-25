*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFH_KR1AT.......................................*
DATA:  BEGIN OF STATUS_ZFH_KR1AT                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFH_KR1AT                     .
CONTROLS: TCTRL_ZFH_KR1AT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFH_KR1AT                     .
TABLES: ZFH_KR1AT                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
