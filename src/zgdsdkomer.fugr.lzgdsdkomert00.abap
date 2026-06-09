*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDSDKOMER......................................*
DATA:  BEGIN OF STATUS_ZGDSDKOMER                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDSDKOMER                    .
CONTROLS: TCTRL_ZGDSDKOMER
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDSDKOMER                    .
TABLES: ZGDSDKOMER                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
