*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63JABATMASTER.................................*
DATA:  BEGIN OF STATUS_ZF63JABATMASTER               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63JABATMASTER               .
CONTROLS: TCTRL_ZF63JABATMASTER
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63JABATMASTER               .
TABLES: ZF63JABATMASTER                .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
