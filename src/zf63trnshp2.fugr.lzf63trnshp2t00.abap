*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63TRNSHP2.....................................*
DATA:  BEGIN OF STATUS_ZF63TRNSHP2                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63TRNSHP2                   .
CONTROLS: TCTRL_ZF63TRNSHP2
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63TRNSHP2                   .
TABLES: ZF63TRNSHP2                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
