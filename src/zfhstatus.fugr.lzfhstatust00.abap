*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFHSTATUS.......................................*
DATA:  BEGIN OF STATUS_ZFHSTATUS                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFHSTATUS                     .
CONTROLS: TCTRL_ZFHSTATUS
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFHSTATUS                     .
TABLES: ZFHSTATUS                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
