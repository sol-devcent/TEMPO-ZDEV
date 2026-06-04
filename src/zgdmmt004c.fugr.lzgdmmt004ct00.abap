*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDMMT004C......................................*
DATA:  BEGIN OF STATUS_ZGDMMT004C                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDMMT004C                    .
CONTROLS: TCTRL_ZGDMMT004C
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDMMT004C                    .
TABLES: ZGDMMT004C                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
