*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZVEND_EVAL......................................*
DATA:  BEGIN OF STATUS_ZVEND_EVAL                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZVEND_EVAL                    .
CONTROLS: TCTRL_ZVEND_EVAL
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZVEND_EVAL                    .
TABLES: ZVEND_EVAL                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
