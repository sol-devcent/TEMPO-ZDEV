*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZWMDT008........................................*
DATA:  BEGIN OF STATUS_ZWMDT008                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZWMDT008                      .
CONTROLS: TCTRL_ZWMDT008
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZWMDT008                      .
TABLES: ZWMDT008                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
