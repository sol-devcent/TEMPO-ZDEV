*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFNR_RANGE......................................*
DATA:  BEGIN OF STATUS_ZFNR_RANGE                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFNR_RANGE                    .
CONTROLS: TCTRL_ZFNR_RANGE
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFNR_RANGE                    .
TABLES: ZFNR_RANGE                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
