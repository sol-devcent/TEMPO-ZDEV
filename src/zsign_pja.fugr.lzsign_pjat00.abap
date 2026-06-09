*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSIGN_PJA.......................................*
DATA:  BEGIN OF STATUS_ZSIGN_PJA                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSIGN_PJA                     .
CONTROLS: TCTRL_ZSIGN_PJA
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSIGN_PJA                     .
TABLES: ZSIGN_PJA                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
