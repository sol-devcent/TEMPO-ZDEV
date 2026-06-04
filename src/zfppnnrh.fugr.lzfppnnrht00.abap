*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFPPNNRH........................................*
DATA:  BEGIN OF STATUS_ZFPPNNRH                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFPPNNRH                      .
CONTROLS: TCTRL_ZFPPNNRH
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFPPNNRH                      .
TABLES: ZFPPNNRH                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
