*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZWMDT001X.......................................*
DATA:  BEGIN OF STATUS_ZWMDT001X                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZWMDT001X                     .
CONTROLS: TCTRL_ZWMDT001X
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZWMDT001X                     .
TABLES: ZWMDT001X                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
