*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSMOV...........................................*
DATA:  BEGIN OF STATUS_ZSMOV                         .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSMOV                         .
CONTROLS: TCTRL_ZSMOV
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSMOV                         .
TABLES: ZSMOV                          .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
