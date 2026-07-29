*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDMMT004B......................................*
DATA:  BEGIN OF STATUS_ZGDMMT004B                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDMMT004B                    .
CONTROLS: TCTRL_ZGDMMT004B
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDMMT004B                    .
TABLES: ZGDMMT004B                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
