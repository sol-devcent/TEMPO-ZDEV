*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZKMMPPDT023.....................................*
DATA:  BEGIN OF STATUS_ZKMMPPDT023                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZKMMPPDT023                   .
CONTROLS: TCTRL_ZKMMPPDT023
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZKMMPPDT023                   .
TABLES: ZKMMPPDT023                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
