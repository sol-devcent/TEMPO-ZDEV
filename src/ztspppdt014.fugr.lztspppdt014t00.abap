*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTSPPPDT014.....................................*
DATA:  BEGIN OF STATUS_ZTSPPPDT014                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTSPPPDT014                   .
CONTROLS: TCTRL_ZTSPPPDT014
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZTSPPPDT014                   .
TABLES: ZTSPPPDT014                    .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
