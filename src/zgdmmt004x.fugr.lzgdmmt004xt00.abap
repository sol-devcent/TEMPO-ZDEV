*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDMMT004X......................................*
DATA:  BEGIN OF STATUS_ZGDMMT004X                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDMMT004X                    .
CONTROLS: TCTRL_ZGDMMT004X
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDMMT004X                    .
TABLES: ZGDMMT004X                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
