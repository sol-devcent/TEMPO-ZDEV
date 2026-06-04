*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSMAT_B2B.......................................*
DATA:  BEGIN OF STATUS_ZSMAT_B2B                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSMAT_B2B                     .
CONTROLS: TCTRL_ZSMAT_B2B
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZSMAT_B2B                     .
TABLES: ZSMAT_B2B                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
