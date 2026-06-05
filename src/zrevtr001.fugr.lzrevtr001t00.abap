*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZREVTR001.......................................*
DATA:  BEGIN OF STATUS_ZREVTR001                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZREVTR001                     .
CONTROLS: TCTRL_ZREVTR001
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZREVTR001                     .
TABLES: ZREVTR001                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
