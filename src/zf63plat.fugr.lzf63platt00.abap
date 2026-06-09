*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63PLAT........................................*
DATA:  BEGIN OF STATUS_ZF63PLAT                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63PLAT                      .
CONTROLS: TCTRL_ZF63PLAT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63PLAT                      .
TABLES: ZF63PLAT                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
