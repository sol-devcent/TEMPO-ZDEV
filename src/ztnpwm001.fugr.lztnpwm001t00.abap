*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTNPWM001.......................................*
DATA:  BEGIN OF STATUS_ZTNPWM001                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTNPWM001                     .
CONTROLS: TCTRL_ZTNPWM001
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTNPWM001                     .
TABLES: ZTNPWM001                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
