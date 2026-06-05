*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSPAKET.........................................*
DATA:  BEGIN OF STATUS_ZSPAKET                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSPAKET                       .
CONTROLS: TCTRL_ZSPAKET
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSPAKET                       .
TABLES: ZSPAKET                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
