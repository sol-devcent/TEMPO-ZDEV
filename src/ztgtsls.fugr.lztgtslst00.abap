*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTGTSLS.........................................*
DATA:  BEGIN OF STATUS_ZTGTSLS                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTGTSLS                       .
CONTROLS: TCTRL_ZTGTSLS
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTGTSLS                       .
TABLES: ZTGTSLS                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
