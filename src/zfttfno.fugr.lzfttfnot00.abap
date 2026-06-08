*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFTTFNO.........................................*
DATA:  BEGIN OF STATUS_ZFTTFNO                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFTTFNO                       .
CONTROLS: TCTRL_ZFTTFNO
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFTTFNO                       .
TABLES: ZFTTFNO                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
