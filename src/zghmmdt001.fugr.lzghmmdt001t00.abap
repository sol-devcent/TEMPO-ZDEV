*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGHMMDT001......................................*
DATA:  BEGIN OF STATUS_ZGHMMDT001                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGHMMDT001                    .
CONTROLS: TCTRL_ZGHMMDT001
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGHMMDT001                    .
TABLES: ZGHMMDT001                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
