*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPPPDT0011....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT0011                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT0011                  .
CONTROLS: TCTRL_ZTSPPPDT0011
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZTSPPPDT0011                  .
TABLES: ZTSPPPDT0011                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
