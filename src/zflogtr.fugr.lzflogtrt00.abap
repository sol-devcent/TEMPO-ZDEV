*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFLOGTR.........................................*
DATA:  BEGIN OF STATUS_ZFLOGTR                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFLOGTR                       .
CONTROLS: TCTRL_ZFLOGTR
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFLOGTR                       .
TABLES: ZFLOGTR                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
