*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFVATFP.........................................*
DATA:  BEGIN OF STATUS_ZFVATFP                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFVATFP                       .
CONTROLS: TCTRL_ZFVATFP
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFVATFP                       .
TABLES: ZFVATFP                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
