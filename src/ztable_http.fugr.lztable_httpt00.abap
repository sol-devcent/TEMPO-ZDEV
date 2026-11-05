*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTDSITDT001.....................................*
DATA:  BEGIN OF STATUS_ZTDSITDT001                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTDSITDT001                   .
CONTROLS: TCTRL_ZTDSITDT001
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZTDSITDT002.....................................*
DATA:  BEGIN OF STATUS_ZTDSITDT002                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTDSITDT002                   .
CONTROLS: TCTRL_ZTDSITDT002
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZTDSITDT003.....................................*
DATA:  BEGIN OF STATUS_ZTDSITDT003                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTDSITDT003                   .
CONTROLS: TCTRL_ZTDSITDT003
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: ZTDSITDT005.....................................*
DATA:  BEGIN OF STATUS_ZTDSITDT005                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTDSITDT005                   .
CONTROLS: TCTRL_ZTDSITDT005
            TYPE TABLEVIEW USING SCREEN '0004'.
*.........table declarations:.................................*
TABLES: *ZTDSITDT001                   .
TABLES: *ZTDSITDT002                   .
TABLES: *ZTDSITDT003                   .
TABLES: *ZTDSITDT005                   .
TABLES: ZTDSITDT001                    .
TABLES: ZTDSITDT002                    .
TABLES: ZTDSITDT003                    .
TABLES: ZTDSITDT005                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
