*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZGHSD_DOC_SO....................................*
DATA:  BEGIN OF STATUS_ZGHSD_DOC_SO                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZGHSD_DOC_SO                  .
CONTROLS: TCTRL_ZGHSD_DOC_SO
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZGHSD_DOC_SO                  .
TABLES: ZGHSD_DOC_SO                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
