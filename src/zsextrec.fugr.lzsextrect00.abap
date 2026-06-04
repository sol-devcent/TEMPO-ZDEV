*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSEXTREC........................................*
DATA:  BEGIN OF STATUS_ZSEXTREC                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSEXTREC                      .
CONTROLS: TCTRL_ZSEXTREC
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSEXTREC                      .
TABLES: ZSEXTREC                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
