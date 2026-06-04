*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZDMPPPDT001.....................................*
DATA:  BEGIN OF STATUS_ZDMPPPDT001                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDMPPPDT001                   .
CONTROLS: TCTRL_ZDMPPPDT001
            TYPE TABLEVIEW USING SCREEN '1020'.
*...processing: ZTSPPPDT012.....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT012                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT012                   .
CONTROLS: TCTRL_ZTSPPPDT012
            TYPE TABLEVIEW USING SCREEN '1100'.
*.........table declarations:.................................*
TABLES: *ZDMPPPDT001                   .
TABLES: *ZTSPPPDT012                   .
TABLES: ZDMPPPDT001                    .
TABLES: ZTSPPPDT012                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
