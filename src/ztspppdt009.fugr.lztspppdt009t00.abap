*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPPPDT009.....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT009                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT009                   .
CONTROLS: TCTRL_ZTSPPPDT009
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPPPDT009                   .
TABLES: ZTSPPPDT009                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
