*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 12.05.2006 at 15:32:19 by user TDS_DEV01
*---------------------------------------------------------------------*
*...processing: ZSCUST_OPP......................................*
DATA:  BEGIN OF STATUS_ZSCUST_OPP                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSCUST_OPP                    .
CONTROLS: TCTRL_ZSCUST_OPP
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZSCUST_OPP                    .
TABLES: ZSCUST_OPP                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
