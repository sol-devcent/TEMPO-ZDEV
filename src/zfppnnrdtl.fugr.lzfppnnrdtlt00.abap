*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFPPNNRDTL......................................*
DATA:  BEGIN OF STATUS_ZFPPNNRDTL                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFPPNNRDTL                    .
CONTROLS: TCTRL_ZFPPNNRDTL
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFPPNNRDTL                    .
TABLES: ZFPPNNRDTL                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
