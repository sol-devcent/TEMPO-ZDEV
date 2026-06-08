*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSTT..........................................*
DATA:  BEGIN OF STATUS_ZFGSTT                        .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSTT                        .
CONTROLS: TCTRL_ZFGSTT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSTT                        .
TABLES: ZFGSTT                         .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
