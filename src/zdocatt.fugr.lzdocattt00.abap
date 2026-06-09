*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDOCATT.........................................*
DATA:  BEGIN OF STATUS_ZDOCATT                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDOCATT                       .
CONTROLS: TCTRL_ZDOCATT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZDOCATT                       .
TABLES: ZDOCATT                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
