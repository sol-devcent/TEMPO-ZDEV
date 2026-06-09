*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63TRNHDR......................................*
DATA:  BEGIN OF STATUS_ZF63TRNHDR                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63TRNHDR                    .
CONTROLS: TCTRL_ZF63TRNHDR
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63TRNHDR                    .
TABLES: ZF63TRNHDR                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
