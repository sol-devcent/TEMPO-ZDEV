*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSD_PO..........................................*
DATA:  BEGIN OF STATUS_ZSD_PO                        .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSD_PO                        .
CONTROLS: TCTRL_ZSD_PO
            TYPE TABLEVIEW USING SCREEN '0100'.
*.........table declarations:.................................*
TABLES: *ZSD_PO                        .
TABLES: ZSD_PO                         .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
