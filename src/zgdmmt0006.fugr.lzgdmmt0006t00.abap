*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDMMT0006......................................*
DATA:  BEGIN OF STATUS_ZGDMMT0006                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDMMT0006                    .
CONTROLS: TCTRL_ZGDMMT0006
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDMMT0006                    .
TABLES: ZGDMMT0006                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
