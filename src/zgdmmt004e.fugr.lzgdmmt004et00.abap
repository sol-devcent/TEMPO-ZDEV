*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDMMT004E......................................*
DATA:  BEGIN OF STATUS_ZGDMMT004E                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDMMT004E                    .
CONTROLS: TCTRL_ZGDMMT004E
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDMMT004E                    .
TABLES: ZGDMMT004E                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
