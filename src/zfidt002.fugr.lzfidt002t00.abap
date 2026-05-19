*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIDT002........................................*
DATA:  BEGIN OF STATUS_ZFIDT002                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIDT002                      .
CONTROLS: TCTRL_ZFIDT002
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFIDT002                      .
TABLES: ZFIDT002                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
