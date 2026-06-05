*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFSFA_JH........................................*
DATA:  BEGIN OF STATUS_ZFSFA_JH                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFSFA_JH                      .
CONTROLS: TCTRL_ZFSFA_JH
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZFSFA_JH                      .
TABLES: ZFSFA_JH                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
