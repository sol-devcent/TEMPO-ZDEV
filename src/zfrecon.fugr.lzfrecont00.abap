*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 19.12.2002 at 10:24:48 by user TDS_DEV01
*---------------------------------------------------------------------*
*...processing: ZFRECON.........................................*
DATA:  BEGIN OF STATUS_ZFRECON                       .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFRECON                       .
CONTROLS: TCTRL_ZFRECON
            TYPE TABLEVIEW USING SCREEN '1000'.
*.........table declarations:.................................*
TABLES: *ZFRECON                       .
TABLES: ZFRECON                        .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
