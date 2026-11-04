*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDMMT0005......................................*
DATA:  BEGIN OF STATUS_ZGDMMT0005                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDMMT0005                    .
CONTROLS: TCTRL_ZGDMMT0005
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDMMT0005                    .
TABLES: ZGDMMT0005                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
