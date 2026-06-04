*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDMMT004Y......................................*
DATA:  BEGIN OF STATUS_ZGDMMT004Y                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDMMT004Y                    .
CONTROLS: TCTRL_ZGDMMT004Y
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDMMT004Y                    .
TABLES: ZGDMMT004Y                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
