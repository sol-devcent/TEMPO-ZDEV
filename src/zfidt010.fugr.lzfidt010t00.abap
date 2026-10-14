*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIDT010........................................*
DATA:  BEGIN OF STATUS_ZFIDT010                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIDT010                      .
CONTROLS: TCTRL_ZFIDT010
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFIDT010                      .
TABLES: ZFIDT010                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
