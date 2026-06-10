*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMPSIKOR1.......................................*
DATA:  BEGIN OF STATUS_ZMPSIKOR1                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMPSIKOR1                     .
CONTROLS: TCTRL_ZMPSIKOR1
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZMPSIKOR1                     .
TABLES: ZMPSIKOR1                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
