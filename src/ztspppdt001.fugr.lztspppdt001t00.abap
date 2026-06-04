*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPPPDT001.....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT001                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT001                   .
CONTROLS: TCTRL_ZTSPPPDT001
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZTSPPPDT001                   .
TABLES: ZTSPPPDT001                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
