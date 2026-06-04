*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZKMMPPDT019.....................................*
DATA:  BEGIN OF STATUS_ZKMMPPDT019                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZKMMPPDT019                   .
CONTROLS: TCTRL_ZKMMPPDT019
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZKMMPPDT019                   .
TABLES: ZKMMPPDT019                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
