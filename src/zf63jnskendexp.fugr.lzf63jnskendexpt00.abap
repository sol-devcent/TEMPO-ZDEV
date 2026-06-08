*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63JNSKENDEXP..................................*
DATA:  BEGIN OF STATUS_ZF63JNSKENDEXP                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63JNSKENDEXP                .
CONTROLS: TCTRL_ZF63JNSKENDEXP
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63JNSKENDEXP                .
TABLES: ZF63JNSKENDEXP                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
