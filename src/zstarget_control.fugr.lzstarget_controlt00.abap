*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSTARGET_CONTROL................................*
DATA:  BEGIN OF STATUS_ZSTARGET_CONTROL              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSTARGET_CONTROL              .
CONTROLS: TCTRL_ZSTARGET_CONTROL
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSTARGET_CONTROL              .
TABLES: ZSTARGET_CONTROL               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
