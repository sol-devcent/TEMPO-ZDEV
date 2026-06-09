*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 20.08.2002 at 22:29:57 by user TDS_DEV01
*---------------------------------------------------------------------*
*...processing: ZSIGN_BM........................................*
DATA:  BEGIN OF STATUS_ZSIGN_BM                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSIGN_BM                      .
CONTROLS: TCTRL_ZSIGN_BM
            TYPE TABLEVIEW USING SCREEN '1111'.
*.........table declarations:.................................*
TABLES: *ZSIGN_BM                      .
TABLES: ZSIGN_BM                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
