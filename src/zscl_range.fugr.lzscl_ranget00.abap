*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSCL_RANGE......................................*
DATA:  BEGIN OF STATUS_ZSCL_RANGE                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSCL_RANGE                    .
CONTROLS: TCTRL_ZSCL_RANGE
            TYPE TABLEVIEW USING SCREEN '1100'.
*.........table declarations:.................................*
TABLES: *ZSCL_RANGE                    .
TABLES: ZSCL_RANGE                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
