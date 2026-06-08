*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63TRNDTL2.....................................*
DATA:  BEGIN OF STATUS_ZF63TRNDTL2                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63TRNDTL2                   .
CONTROLS: TCTRL_ZF63TRNDTL2
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63TRNDTL2                   .
TABLES: ZF63TRNDTL2                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
