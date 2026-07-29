*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGDMMT004D......................................*
DATA:  BEGIN OF STATUS_ZGDMMT004D                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGDMMT004D                    .
CONTROLS: TCTRL_ZGDMMT004D
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZGDMMT004D                    .
TABLES: ZGDMMT004D                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
