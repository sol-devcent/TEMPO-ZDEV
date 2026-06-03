*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSD_ABGRU.......................................*
DATA:  BEGIN OF STATUS_ZSD_ABGRU                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSD_ABGRU                     .
CONTROLS: TCTRL_ZSD_ABGRU
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZSD_ABGRU                     .
TABLES: ZSD_ABGRU                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
