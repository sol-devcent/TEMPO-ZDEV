*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFVATA3.........................................*
DATA:  BEGIN OF STATUS_ZFVATA3                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFVATA3                       .
CONTROLS: TCTRL_ZFVATA3
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFVATA3                       .
TABLES: ZFVATA3                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
