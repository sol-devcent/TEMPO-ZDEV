*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSUOM_B2B.......................................*
DATA:  BEGIN OF STATUS_ZSUOM_B2B                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSUOM_B2B                     .
CONTROLS: TCTRL_ZSUOM_B2B
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZSUOM_B2B                     .
TABLES: ZSUOM_B2B                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
