*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIDT013........................................*
DATA:  BEGIN OF STATUS_ZFIDT013                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIDT013                      .
CONTROLS: TCTRL_ZFIDT013
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFIDT013                      .
TABLES: ZFIDT013                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
