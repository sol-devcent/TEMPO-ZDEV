*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSMAP_B2B.......................................*
DATA:  BEGIN OF STATUS_ZSMAP_B2B                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSMAP_B2B                     .
CONTROLS: TCTRL_ZSMAP_B2B
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSMAP_B2B                     .
TABLES: ZSMAP_B2B                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
