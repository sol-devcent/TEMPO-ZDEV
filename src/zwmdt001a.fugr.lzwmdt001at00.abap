*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZWMDT001A.......................................*
DATA:  BEGIN OF STATUS_ZWMDT001A                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZWMDT001A                     .
CONTROLS: TCTRL_ZWMDT001A
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZWMDT001A                     .
TABLES: ZWMDT001A                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
