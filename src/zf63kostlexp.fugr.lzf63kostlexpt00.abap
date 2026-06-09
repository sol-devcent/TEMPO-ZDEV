*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63KOSTLEXP....................................*
DATA:  BEGIN OF STATUS_ZF63KOSTLEXP                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63KOSTLEXP                  .
CONTROLS: TCTRL_ZF63KOSTLEXP
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63KOSTLEXP                  .
TABLES: ZF63KOSTLEXP                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
