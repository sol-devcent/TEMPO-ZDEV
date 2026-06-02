*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFBICHECK.......................................*
DATA:  BEGIN OF STATUS_ZFBICHECK                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFBICHECK                     .
CONTROLS: TCTRL_ZFBICHECK
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFBICHECK                     .
TABLES: ZFBICHECK                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
