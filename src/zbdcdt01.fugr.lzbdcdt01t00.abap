*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZBDCDT01........................................*
DATA:  BEGIN OF STATUS_ZBDCDT01                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBDCDT01                      .
CONTROLS: TCTRL_ZBDCDT01
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZBDCDT01                      .
TABLES: ZBDCDT01                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
