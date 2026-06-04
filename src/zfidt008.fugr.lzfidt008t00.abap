*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIDT008........................................*
DATA:  BEGIN OF STATUS_ZFIDT008                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIDT008                      .
CONTROLS: TCTRL_ZFIDT008
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFIDT008                      .
TABLES: ZFIDT008                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
