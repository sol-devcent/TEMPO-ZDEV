*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFTRANSTTF......................................*
DATA:  BEGIN OF STATUS_ZFTRANSTTF                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFTRANSTTF                    .
CONTROLS: TCTRL_ZFTRANSTTF
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFTRANSTTF                    .
TABLES: ZFTRANSTTF                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
