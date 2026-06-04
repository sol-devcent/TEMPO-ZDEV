*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZKMMPPDT024.....................................*
DATA:  BEGIN OF STATUS_ZKMMPPDT024                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZKMMPPDT024                   .
CONTROLS: TCTRL_ZKMMPPDT024
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZKMMPPDT024                   .
TABLES: ZKMMPPDT024                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
