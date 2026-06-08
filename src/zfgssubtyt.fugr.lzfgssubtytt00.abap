*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFGSSUBTYT......................................*
DATA:  BEGIN OF STATUS_ZFGSSUBTYT                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFGSSUBTYT                    .
CONTROLS: TCTRL_ZFGSSUBTYT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFGSSUBTYT                    .
TABLES: ZFGSSUBTYT                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
