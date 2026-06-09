*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63MASTER......................................*
DATA:  BEGIN OF STATUS_ZF63MASTER                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63MASTER                    .
CONTROLS: TCTRL_ZF63MASTER
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63MASTER                    .
TABLES: ZF63MASTER                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
