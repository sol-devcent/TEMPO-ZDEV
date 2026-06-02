*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZPROJECT........................................*
DATA:  BEGIN OF STATUS_ZPROJECT                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPROJECT                      .
CONTROLS: TCTRL_ZPROJECT
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPROJECT                      .
TABLES: ZPROJECT                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
