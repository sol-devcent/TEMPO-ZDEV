*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZSD_ABGRU2......................................*
DATA:  BEGIN OF STATUS_ZSD_ABGRU2                    .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZSD_ABGRU2                    .
CONTROLS: TCTRL_ZSD_ABGRU2
            TYPE TABLEVIEW USING SCREEN '1020'.
*.........table declarations:.................................*
TABLES: *ZSD_ABGRU2                    .
TABLES: ZSD_ABGRU2                     .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
