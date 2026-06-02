*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSCR_CONTROL....................................*
DATA:  BEGIN OF STATUS_ZSCR_CONTROL                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSCR_CONTROL                  .
CONTROLS: TCTRL_ZSCR_CONTROL
            TYPE TABLEVIEW USING SCREEN '1100'.
*...processing: ZSCR_CONTROL01..................................*
DATA:  BEGIN OF STATUS_ZSCR_CONTROL01                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSCR_CONTROL01                .
CONTROLS: TCTRL_ZSCR_CONTROL01
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSCR_CONTROL                  .
TABLES: *ZSCR_CONTROL01                .
TABLES: ZSCR_CONTROL                   .
TABLES: ZSCR_CONTROL01                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
