*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSCL_USER.......................................*
DATA:  BEGIN OF STATUS_ZSCL_USER                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSCL_USER                     .
CONTROLS: TCTRL_ZSCL_USER
            TYPE TABLEVIEW USING SCREEN '1100'.
*.........table declarations:.................................*
TABLES: *ZSCL_USER                     .
TABLES: ZSCL_USER                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
