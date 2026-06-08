*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63MASTERKEND..................................*
DATA:  BEGIN OF STATUS_ZF63MASTERKEND                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63MASTERKEND                .
CONTROLS: TCTRL_ZF63MASTERKEND
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63MASTERKEND                .
TABLES: ZF63MASTERKEND                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
