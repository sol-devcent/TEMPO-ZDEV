*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMPSIKOR........................................*
DATA:  BEGIN OF STATUS_ZMPSIKOR                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMPSIKOR                      .
CONTROLS: TCTRL_ZMPSIKOR
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZMPSIKOR                      .
TABLES: ZMPSIKOR                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
