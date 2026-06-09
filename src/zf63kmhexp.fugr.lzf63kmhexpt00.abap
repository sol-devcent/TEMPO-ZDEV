*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63KMHEXP......................................*
DATA:  BEGIN OF STATUS_ZF63KMHEXP                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63KMHEXP                    .
CONTROLS: TCTRL_ZF63KMHEXP
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63KMHEXP                    .
TABLES: ZF63KMHEXP                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
