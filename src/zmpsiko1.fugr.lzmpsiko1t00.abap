*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMPSIKO1........................................*
DATA:  BEGIN OF STATUS_ZMPSIKO1                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMPSIKO1                      .
CONTROLS: TCTRL_ZMPSIKO1
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZMPSIKO1                      .
TABLES: ZMPSIKO1                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
