*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZFE_KDJNSTR.....................................*
DATA:  BEGIN OF STATUS_ZFE_KDJNSTR                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFE_KDJNSTR                   .
CONTROLS: TCTRL_ZFE_KDJNSTR
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFE_KDJNSTR                   .
TABLES: ZFE_KDJNSTR                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
