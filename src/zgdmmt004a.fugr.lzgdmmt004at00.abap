*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDMMT004A......................................*
DATA:  BEGIN OF STATUS_ZGDMMT004A                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDMMT004A                    .
CONTROLS: TCTRL_ZGDMMT004A
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDMMT004A                    .
TABLES: ZGDMMT004A                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
