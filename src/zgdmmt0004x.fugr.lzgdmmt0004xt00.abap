*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDMMT0004X.....................................*
DATA:  BEGIN OF STATUS_ZGDMMT0004X                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDMMT0004X                   .
CONTROLS: TCTRL_ZGDMMT0004X
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDMMT0004X                   .
TABLES: ZGDMMT0004X                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
