*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFVATA2.........................................*
DATA:  BEGIN OF STATUS_ZFVATA2                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFVATA2                       .
CONTROLS: TCTRL_ZFVATA2
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFVATA2                       .
TABLES: ZFVATA2                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
