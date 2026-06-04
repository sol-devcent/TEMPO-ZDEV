*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSEXTRECREAS....................................*
DATA:  BEGIN OF STATUS_ZSEXTRECREAS                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSEXTRECREAS                  .
CONTROLS: TCTRL_ZSEXTRECREAS
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSEXTRECREAS                  .
TABLES: ZSEXTRECREAS                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
