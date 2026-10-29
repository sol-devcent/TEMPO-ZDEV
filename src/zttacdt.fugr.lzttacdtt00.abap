*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTTACDT.........................................*
DATA:  BEGIN OF STATUS_ZTTACDT                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTTACDT                       .
CONTROLS: TCTRL_ZTTACDT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTTACDT                       .
TABLES: ZTTACDT                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
