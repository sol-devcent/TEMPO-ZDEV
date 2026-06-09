*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTR_ORDER_MST...................................*
DATA:  BEGIN OF STATUS_ZTR_ORDER_MST                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTR_ORDER_MST                 .
CONTROLS: TCTRL_ZTR_ORDER_MST
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTR_ORDER_MST                 .
TABLES: ZTR_ORDER_MST                  .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
