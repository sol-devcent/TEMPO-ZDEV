*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDTX_0014......................................*
DATA:  BEGIN OF STATUS_ZGDTX_0014                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDTX_0014                    .
CONTROLS: TCTRL_ZGDTX_0014
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDTX_0014                    .
TABLES: ZGDTX_0014                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
