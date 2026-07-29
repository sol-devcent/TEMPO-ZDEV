*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIPRCTR........................................*
DATA:  BEGIN OF STATUS_ZFIPRCTR                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIPRCTR                      .
CONTROLS: TCTRL_ZFIPRCTR
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFIPRCTR                      .
TABLES: ZFIPRCTR                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
