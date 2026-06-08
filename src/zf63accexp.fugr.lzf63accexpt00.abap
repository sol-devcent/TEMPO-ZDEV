*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63ACCEXP......................................*
DATA:  BEGIN OF STATUS_ZF63ACCEXP                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63ACCEXP                    .
CONTROLS: TCTRL_ZF63ACCEXP
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63ACCEXP                    .
TABLES: ZF63ACCEXP                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
