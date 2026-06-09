*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 23.07.2002 at 11:01:14 by user TDS_DEV01
*---------------------------------------------------------------------*
*...processing: ZSLOCKANVAS.....................................*
DATA:  BEGIN OF STATUS_ZSLOCKANVAS                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSLOCKANVAS                   .
CONTROLS: TCTRL_ZSLOCKANVAS
            TYPE TABLEVIEW USING SCREEN '1070'.
*.........table declarations:.................................*
TABLES: *ZSLOCKANVAS                   .
TABLES: ZSLOCKANVAS                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
