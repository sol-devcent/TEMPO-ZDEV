*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZWMDT013........................................*
DATA:  BEGIN OF STATUS_ZWMDT013                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZWMDT013                      .
CONTROLS: TCTRL_ZWMDT013
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZWMDT013                      .
TABLES: ZWMDT013                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
