*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSL_HSALES......................................*
DATA:  BEGIN OF STATUS_ZSL_HSALES                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSL_HSALES                    .
CONTROLS: TCTRL_ZSL_HSALES
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSL_HSALES                    .
TABLES: ZSL_HSALES                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
