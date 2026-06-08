*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63GTYPE.......................................*
DATA:  BEGIN OF STATUS_ZF63GTYPE                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63GTYPE                     .
CONTROLS: TCTRL_ZF63GTYPE
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63GTYPE                     .
TABLES: ZF63GTYPE                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
