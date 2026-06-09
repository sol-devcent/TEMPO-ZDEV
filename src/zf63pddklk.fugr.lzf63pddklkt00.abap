*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZF63PDDKLK......................................*
DATA:  BEGIN OF STATUS_ZF63PDDKLK                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZF63PDDKLK                    .
CONTROLS: TCTRL_ZF63PDDKLK
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZF63PDDKLK                    .
TABLES: ZF63PDDKLK                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
