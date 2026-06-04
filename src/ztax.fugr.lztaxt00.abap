*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 13.09.2002 at 17:45:54 by user TDS_DEV01
*---------------------------------------------------------------------*
*...processing: ZTAX............................................*
DATA:  BEGIN OF STATUS_ZTAX                          .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTAX                          .
CONTROLS: TCTRL_ZTAX
            TYPE TABLEVIEW USING SCREEN '1030'.
*.........table declarations:.................................*
TABLES: *ZTAX                          .
TABLES: ZTAX                           .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
