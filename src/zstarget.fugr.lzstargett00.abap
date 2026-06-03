*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSTARGET........................................*
DATA:  BEGIN OF STATUS_ZSTARGET                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSTARGET                      .
CONTROLS: TCTRL_ZSTARGET
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZSTARGET                      .
TABLES: ZSTARGET                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
