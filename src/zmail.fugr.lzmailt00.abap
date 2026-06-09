*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMAIL...........................................*
DATA:  BEGIN OF STATUS_ZMAIL                         .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMAIL                         .
CONTROLS: TCTRL_ZMAIL
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZMAIL                         .
TABLES: ZMAIL                          .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
