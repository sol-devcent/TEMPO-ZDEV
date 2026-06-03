*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPPPDT011.....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT011                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT011                   .
CONTROLS: TCTRL_ZTSPPPDT011
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPPPDT011                   .
TABLES: ZTSPPPDT011                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
