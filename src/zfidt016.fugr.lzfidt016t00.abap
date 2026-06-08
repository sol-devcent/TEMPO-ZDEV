*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFIDT016........................................*
DATA:  BEGIN OF STATUS_ZFIDT016                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFIDT016                      .
CONTROLS: TCTRL_ZFIDT016
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFIDT016                      .
TABLES: ZFIDT016                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
