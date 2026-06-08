*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFNRCUSTM.......................................*
DATA:  BEGIN OF STATUS_ZFNRCUSTM                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFNRCUSTM                     .
CONTROLS: TCTRL_ZFNRCUSTM
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFNRCUSTM                     .
TABLES: ZFNRCUSTM                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
