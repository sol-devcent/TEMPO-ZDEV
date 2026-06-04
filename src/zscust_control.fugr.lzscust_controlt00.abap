*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSCUST_CONTROL..................................*
DATA:  BEGIN OF STATUS_ZSCUST_CONTROL                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSCUST_CONTROL                .
CONTROLS: TCTRL_ZSCUST_CONTROL
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSCUST_CONTROL                .
TABLES: ZSCUST_CONTROL                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
