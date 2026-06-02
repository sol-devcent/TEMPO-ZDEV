*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSL_DSALES......................................*
DATA:  BEGIN OF STATUS_ZSL_DSALES                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSL_DSALES                    .
CONTROLS: TCTRL_ZSL_DSALES
            TYPE TABLEVIEW USING SCREEN '1012'.
*.........table declarations:.................................*
TABLES: *ZSL_DSALES                    .
TABLES: ZSL_DSALES                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
