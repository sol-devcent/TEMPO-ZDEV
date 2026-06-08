*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 06.02.2007 at 10:45:02 by user TDS_DEV01
*---------------------------------------------------------------------*
*...processing: ZNRMAP..........................................*
DATA:  BEGIN OF STATUS_ZNRMAP                        .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZNRMAP                        .
CONTROLS: TCTRL_ZNRMAP
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZNRMAP                        .
TABLES: ZNRMAP                         .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
