*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSERR_B2B.......................................*
DATA:  BEGIN OF STATUS_ZSERR_B2B                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSERR_B2B                     .
CONTROLS: TCTRL_ZSERR_B2B
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZSERR_B2B                     .
TABLES: ZSERR_B2B                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
