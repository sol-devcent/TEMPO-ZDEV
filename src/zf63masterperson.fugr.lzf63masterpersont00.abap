*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63MASTERPERSON................................*
DATA:  BEGIN OF STATUS_ZF63MASTERPERSON              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63MASTERPERSON              .
CONTROLS: TCTRL_ZF63MASTERPERSON
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63MASTERPERSON              .
TABLES: ZF63MASTERPERSON               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
