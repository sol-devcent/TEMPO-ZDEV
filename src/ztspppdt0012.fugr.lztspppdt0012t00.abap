*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPPPDT0012....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT0012                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT0012                  .
CONTROLS: TCTRL_ZTSPPPDT0012
            TYPE TABLEVIEW USING SCREEN '0010'.
*.........table declarations:.................................*
TABLES: *ZTSPPPDT0012                  .
TABLES: ZTSPPPDT0012                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
