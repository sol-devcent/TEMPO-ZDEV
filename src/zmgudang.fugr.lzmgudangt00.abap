*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZMGUDANG........................................*
DATA:  BEGIN OF STATUS_ZMGUDANG                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZMGUDANG                      .
CONTROLS: TCTRL_ZMGUDANG
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZMGUDANG                      .
TABLES: ZMGUDANG                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
