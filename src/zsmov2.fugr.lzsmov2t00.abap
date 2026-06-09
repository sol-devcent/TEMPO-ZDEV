*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSMOV2..........................................*
DATA:  BEGIN OF STATUS_ZSMOV2                        .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSMOV2                        .
CONTROLS: TCTRL_ZSMOV2
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSMOV2                        .
TABLES: ZSMOV2                         .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
