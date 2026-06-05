*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSPAKET_DISC....................................*
DATA:  BEGIN OF STATUS_ZSPAKET_DISC                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSPAKET_DISC                  .
CONTROLS: TCTRL_ZSPAKET_DISC
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSPAKET_DISC                  .
TABLES: ZSPAKET_DISC                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
