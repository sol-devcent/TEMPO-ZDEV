*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMMPRNT.........................................*
DATA:  BEGIN OF STATUS_ZMMPRNT                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMMPRNT                       .
CONTROLS: TCTRL_ZMMPRNT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZMMPRNT                       .
TABLES: ZMMPRNT                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
