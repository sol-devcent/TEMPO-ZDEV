*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZWMPALVND.......................................*
DATA:  BEGIN OF STATUS_ZWMPALVND                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZWMPALVND                     .
CONTROLS: TCTRL_ZWMPALVND
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZWMPALVND                     .
TABLES: ZWMPALVND                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
