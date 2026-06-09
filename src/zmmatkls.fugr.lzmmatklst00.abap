*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMMATKLS........................................*
DATA:  BEGIN OF STATUS_ZMMATKLS                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMMATKLS                      .
CONTROLS: TCTRL_ZMMATKLS
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZMMATKLS                      .
TABLES: ZMMATKLS                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
