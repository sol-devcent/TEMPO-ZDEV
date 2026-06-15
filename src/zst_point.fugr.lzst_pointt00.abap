*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZST_POINT.......................................*
DATA:  BEGIN OF STATUS_ZST_POINT                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZST_POINT                     .
CONTROLS: TCTRL_ZST_POINT
            TYPE TABLEVIEW USING SCREEN '1100'.
*.........table declarations:.................................*
TABLES: *ZST_POINT                     .
TABLES: ZST_POINT                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
