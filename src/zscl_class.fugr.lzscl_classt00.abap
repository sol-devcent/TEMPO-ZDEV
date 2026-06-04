*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSCL_CLASS......................................*
DATA:  BEGIN OF STATUS_ZSCL_CLASS                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSCL_CLASS                    .
CONTROLS: TCTRL_ZSCL_CLASS
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSCL_CLASS                    .
TABLES: ZSCL_CLASS                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
