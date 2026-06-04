*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFNRSTATUS......................................*
DATA:  BEGIN OF STATUS_ZFNRSTATUS                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFNRSTATUS                    .
CONTROLS: TCTRL_ZFNRSTATUS
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFNRSTATUS                    .
TABLES: ZFNRSTATUS                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
