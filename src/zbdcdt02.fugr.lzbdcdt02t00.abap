*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBDCDT02........................................*
DATA:  BEGIN OF STATUS_ZBDCDT02                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBDCDT02                      .
CONTROLS: TCTRL_ZBDCDT02
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZBDCDT02                      .
TABLES: ZBDCDT02                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
