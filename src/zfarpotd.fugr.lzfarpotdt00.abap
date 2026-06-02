*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFARPOTD........................................*
DATA:  BEGIN OF STATUS_ZFARPOTD                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFARPOTD                      .
CONTROLS: TCTRL_ZFARPOTD
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZFARPOTD                      .
TABLES: ZFARPOTD                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
