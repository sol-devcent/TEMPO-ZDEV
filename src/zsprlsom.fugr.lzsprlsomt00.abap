*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 15.07.2005 at 10:59:27 by user TDS_DEV01
*---------------------------------------------------------------------*
*...processing: ZSPRLSOM........................................*
DATA:  BEGIN OF STATUS_ZSPRLSOM                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSPRLSOM                      .
CONTROLS: TCTRL_ZSPRLSOM
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZSPRLSOM                      .
TABLES: ZSPRLSOM                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
