*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZCODT008........................................*
DATA:  BEGIN OF STATUS_ZCODT008                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZCODT008                      .
CONTROLS: TCTRL_ZCODT008
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZCODT008                      .
TABLES: ZCODT008                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
