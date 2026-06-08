*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSMAT2_B2B......................................*
DATA:  BEGIN OF STATUS_ZSMAT2_B2B                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSMAT2_B2B                    .
CONTROLS: TCTRL_ZSMAT2_B2B
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSMAT2_B2B                    .
TABLES: ZSMAT2_B2B                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
