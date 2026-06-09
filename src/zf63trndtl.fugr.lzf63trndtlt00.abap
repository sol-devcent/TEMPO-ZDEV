*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63TRNDTL......................................*
DATA:  BEGIN OF STATUS_ZF63TRNDTL                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63TRNDTL                    .
CONTROLS: TCTRL_ZF63TRNDTL
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63TRNDTL                    .
TABLES: ZF63TRNDTL                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
