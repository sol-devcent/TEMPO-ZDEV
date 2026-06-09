*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63TRNSHP......................................*
DATA:  BEGIN OF STATUS_ZF63TRNSHP                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63TRNSHP                    .
CONTROLS: TCTRL_ZF63TRNSHP
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63TRNSHP                    .
TABLES: ZF63TRNSHP                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
