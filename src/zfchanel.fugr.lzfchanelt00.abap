*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFCHANEL........................................*
DATA:  BEGIN OF STATUS_ZFCHANEL                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFCHANEL                      .
CONTROLS: TCTRL_ZFCHANEL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFCHANEL                      .
TABLES: ZFCHANEL                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
