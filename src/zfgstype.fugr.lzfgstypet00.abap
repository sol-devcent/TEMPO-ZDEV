*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSTYPE........................................*
DATA:  BEGIN OF STATUS_ZFGSTYPE                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSTYPE                      .
CONTROLS: TCTRL_ZFGSTYPE
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSTYPE                      .
TABLES: ZFGSTYPE                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
