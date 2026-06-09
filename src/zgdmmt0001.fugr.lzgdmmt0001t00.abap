*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDMMT0001......................................*
DATA:  BEGIN OF STATUS_ZGDMMT0001                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDMMT0001                    .
CONTROLS: TCTRL_ZGDMMT0001
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDMMT0001                    .
TABLES: ZGDMMT0001                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
