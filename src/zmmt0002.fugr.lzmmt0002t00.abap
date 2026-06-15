*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMMT0002........................................*
DATA:  BEGIN OF STATUS_ZMMT0002                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMMT0002                      .
CONTROLS: TCTRL_ZMMT0002
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZMMT0002                      .
TABLES: ZMMT0002                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
