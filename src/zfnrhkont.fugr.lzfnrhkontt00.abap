*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 22.02.2007 at 15:42:18 by user TDS_DEV01
*---------------------------------------------------------------------*
*...processing: ZFNRHKONT.......................................*
DATA:  BEGIN OF STATUS_ZFNRHKONT                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFNRHKONT                     .
CONTROLS: TCTRL_ZFNRHKONT
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZFNRHKONT                     .
TABLES: ZFNRHKONT                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
