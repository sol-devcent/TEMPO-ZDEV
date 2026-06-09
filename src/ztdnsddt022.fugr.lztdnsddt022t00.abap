*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZTDNSDDT022.....................................*
DATA:  BEGIN OF STATUS_ZTDNSDDT022                   .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTDNSDDT022                   .
CONTROLS: TCTRL_ZTDNSDDT022
            TYPE TABLEVIEW USING SCREEN '1020'.
*...processing: ZTDNSDDT022D....................................*
DATA:  BEGIN OF STATUS_ZTDNSDDT022D                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZTDNSDDT022D                  .
CONTROLS: TCTRL_ZTDNSDDT022D
            TYPE TABLEVIEW USING SCREEN '1030'.
*.........table declarations:.................................*
TABLES: *ZTDNSDDT022                   .
TABLES: *ZTDNSDDT022D                  .
TABLES: ZTDNSDDT022                    .
TABLES: ZTDNSDDT022D                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
