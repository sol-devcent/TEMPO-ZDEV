*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSPAKET_CONTROL.................................*
DATA:  BEGIN OF STATUS_ZSPAKET_CONTROL               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSPAKET_CONTROL               .
CONTROLS: TCTRL_ZSPAKET_CONTROL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSPAKET_CONTROL               .
TABLES: ZSPAKET_CONTROL                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
